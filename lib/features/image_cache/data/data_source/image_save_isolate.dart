import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/image_download_task.dart';
import '../models/image_model.dart';
import '../models/image_save_result.dart';

class ImageSaveIsolate {
  // ─── Concurrency Control ────────────────────────────────────────────────────
  static const int _maxConcurrent = 5;
  static int _activeCount = 0;
  static final Queue<_PendingTask> _queue = Queue();

  // ─── URL Deduplication ──────────────────────────────────────────────────────
  /// Tracks URLs that are queued, actively processing, or have succeeded.
  /// URLs are never removed from this set — once succeeded, always skipped.
  static final Set<String> _seenUrls = {};

  // ─── Public API ─────────────────────────────────────────────────────────────
  static Future<bool> deleteImage(ImageModel imageModel) {
    final completer = Completer<bool>();

    _queue.add(
      _PendingTask(
        type: _TaskType.delete,
        payload: {'filePath': imageModel.filePath},
        completer: completer,
      ),
    );

    _dispatch();
    return completer.future;
  }

  static Future<ImageSaveResult?> downloadImage(String url) async {
    // Skip if this URL is already queued, in-flight, or previously succeeded.
    if (_seenUrls.contains(url)) return null;

    _seenUrls.add(url);

    final directory = await getApplicationDocumentsDirectory();
    final urlFileName = url.split('/').last.split('.').first;
    final urlFileExtension = url.split('.').last;
    final fileExtension = urlFileExtension.length <= 4
        ? urlFileExtension
        : 'jpg';
    final fileName =
        '$urlFileName-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final filePath = '${directory.path}/$fileName';

    final completer = Completer<ImageSaveResult>();

    _queue.add(
      _PendingTask(
        type: _TaskType.download,
        payload: {
          'url': url,
          'task': ImageDownloadTask(url: url, filePath: filePath),
        },
        completer: completer,
      ),
    );

    _dispatch();

    final result = await completer.future;

    // If the download failed, remove from seen so it can be retried later.
    if (!result.success) {
      _seenUrls.remove(url);
    }

    return result;
  }

  // ─── Scheduler ──────────────────────────────────────────────────────────────
  static void _dispatch() {
    while (_activeCount < _maxConcurrent && _queue.isNotEmpty) {
      final pending = _queue.removeFirst();
      _activeCount++;
      _run(pending).whenComplete(() {
        _activeCount--;
        _dispatch();
      });
    }
  }

  static Future<void> _run(_PendingTask pending) async {
    final responsePort = ReceivePort();

    try {
      switch (pending.type) {
        case _TaskType.download:
          await Isolate.spawn(_entryPoint, {
            'sendPort': responsePort.sendPort,
            'task': pending.payload['task'] as ImageDownloadTask,
          });

          await for (final message in responsePort) {
            if (message is ImageSaveResult) {
              (pending.completer as Completer<ImageSaveResult>).complete(
                message,
              );
              break;
            }
          }

        case _TaskType.delete:
          await Isolate.spawn(_deleteEntryPoint, {
            'sendPort': responsePort.sendPort,
            'filePath': pending.payload['filePath'] as String,
          });

          await for (final message in responsePort) {
            if (message is bool) {
              (pending.completer as Completer<bool>).complete(message);
              break;
            }
          }
      }
    } catch (e) {
      final c = pending.completer;
      if (pending.type == _TaskType.download) {
        final url = pending.payload['url'] as String;
        final result = ImageSaveResult(
          url: url,
          filePath: '',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: false,
          error: e.toString(),
        );
        (c as Completer<ImageSaveResult>).complete(result);
        // Remove from seen so the URL can be retried.
        _seenUrls.remove(url);
      } else {
        (c as Completer<bool>).complete(false);
      }
    } finally {
      responsePort.close();
    }
  }

  // ─── Isolate Entry Points ───────────────────────────────────────────────────
  static void _entryPoint(dynamic message) async {
    final sendPort = message['sendPort'] as SendPort;
    final task = message['task'] as ImageDownloadTask;

    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(task.url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        final file = File(task.filePath);
        await file.writeAsBytes(bytes);

        sendPort.send(
          ImageSaveResult(
            url: task.url,
            filePath: task.filePath,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } else {
        final errorBody = await response.transform(utf8.decoder).join();
        sendPort.send(
          ImageSaveResult(
            url: task.url,
            filePath: '',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            success: false,
            error:
                'HTTP ${response.statusCode} - Failed to download. $errorBody.',
          ),
        );
      }
    } catch (e) {
      sendPort.send(
        ImageSaveResult(
          url: task.url,
          filePath: '',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: false,
          error: e.toString(),
        ),
      );
    }

    Isolate.exit();
  }

  static void _deleteEntryPoint(dynamic message) async {
    final sendPort = message['sendPort'] as SendPort;
    final filePath = message['filePath'] as String;

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        sendPort.send(true);
      } else {
        sendPort.send(false);
      }
    } catch (_) {
      sendPort.send(false);
    }

    Isolate.exit();
  }
}

// ─── Internal Types ─────────────────────────────────────────────────────────
enum _TaskType { download, delete }

class _PendingTask {
  final _TaskType type;
  final Map<String, dynamic> payload;
  final Completer completer;

  const _PendingTask({
    required this.type,
    required this.payload,
    required this.completer,
  });
}
