import 'dart:async';

import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import 'package:toastification/toastification.dart';
export 'package:toastification/toastification.dart'
    show ToastificationType, ToastificationStyle;

class Overlays {
  static void showToast({
    required String title,
    required BuildContext context,
    String? message,
    ToastificationType type = ToastificationType.success,
    ToastificationStyle style = ToastificationStyle.flat,
    VoidCallback? onTap,
  }) {
    Toastification()
      ..dismissAll()
      ..show(
        context: context,
        type: type,
        style: style,
        callbacks: ToastificationCallbacks(
          onTap: onTap == null ? null : (value) => onTap(),
        ),
        title: TextWidget(title, maxLines: null),
        autoCloseDuration: const Duration(seconds: 8),
        description: message?.toText(
          maxLines: null,
        ),
      );
  }

  static Future<List<T>?> showMultipleSelectionPopup<T>({
    required List<T> items,
    required String title,
    required Function(List<T> items) onConfirm,
    required VoidCallback onCancel,
    String Function(T value)? displayBuilder,
    List<T> selectedItems = const [],
    dynamic Function(T)? keyBuilder,
  }) async {
    return await showDialog<List<T>>(
      context: RoutesClass.context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        alignment: Alignment.center,
        child: MultiSelectPopup<T>(
          items: items,
          title: title,
          onConfirm: onConfirm,
          onCancel: onCancel,
          displayBuilder: displayBuilder,
          selectedItems: selectedItems,
          keyBuilder: keyBuilder,
        ),
      ),
    );
  }

  static Future<T?> showSingleSelectionPopup<T>({
    required List<T> items,
    required String title,
    required String Function(T value) displayBuilder,
    List<T> Function(String query)? filterBuilder,
  }) async {
    return await showDialog(
      context: RoutesClass.context!,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        alignment: Alignment.center,
        child: SingleSelectPopup<T>(
          items: items,
          title: title,
          displayBuilder: displayBuilder,
          filterBuilder: filterBuilder,
        ),
      ),
    );
  }

  // Helper function to show the delete confirmation popup
  static void showDeleteConfirmationPopup({
    String? title,
    String? itemName,
    String? description,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: RoutesClass.context!,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        alignment: Alignment.center,
        child: DeleteConfirmationPopup(
          title: title,
          itemName: itemName,
          description: description,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
      ),
    );
  }
}

class LoadingDialogManager {
  static final LoadingDialogManager _instance =
      LoadingDialogManager._internal();

  factory LoadingDialogManager() => _instance;

  LoadingDialogManager._internal();

  BuildContext? _dialogContext;
  Timer? _messageTimer;
  int _currentMessageIndex = 0;
  final ValueNotifier<String> _messageNotifier = ValueNotifier<String>('');

  final List<String> _loadingMessages = [
    'Processing your request...',
    'Almost there...',
    'Just a moment...',
    'Finalizing...',
    'Please wait...',
  ];

  bool get isShowing => _dialogContext != null;

  void show(
    BuildContext context, {
    List<String>? customMessages,
    int textIntervalSeconds = 8,
  }) {
    if (isShowing) return;

    final messages = customMessages ?? _loadingMessages;
    _currentMessageIndex = 0;
    _messageNotifier.value = messages[0];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        _dialogContext = dialogContext;

        // Start the timer to cycle through messages
        _startMessageTimer(messages, textIntervalSeconds: textIntervalSeconds);

        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<String>(
                    valueListenable: _messageNotifier,
                    builder: (context, message, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          message,
                          key: ValueKey<String>(message),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _cleanup();
    });
  }

  void _startMessageTimer(
    List<String> messages, {
    int textIntervalSeconds = 8,
  }) {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(Duration(seconds: textIntervalSeconds), (
      timer,
    ) {
      if (_currentMessageIndex < messages.length - 1) {
        _currentMessageIndex++;
        _messageNotifier.value = messages[_currentMessageIndex];
      } else {
        // Stop the timer when we reach the last message
        timer.cancel();
      }
    });
  }

  void hide() {
    if (!isShowing) return;

    _messageTimer?.cancel();
    _messageTimer = null;

    if (_dialogContext != null && _dialogContext!.mounted) {
      Navigator.of(_dialogContext!).pop();
    }

    _cleanup();
  }

  void _cleanup() {
    _messageTimer?.cancel();
    _messageTimer = null;
    _dialogContext = null;
    _currentMessageIndex = 0;
    _messageNotifier.value = '';
  }

  void dispose() {
    _cleanup();
    _messageNotifier.dispose();
  }
}

// Extension for easy access
extension LoadingDialogExtension on BuildContext {
  void showLoadingDialog({
    List<String>? customMessages,
    int textIntervalSeconds = 8,
  }) {
    LoadingDialogManager().show(
      this,
      customMessages: customMessages,
      textIntervalSeconds: textIntervalSeconds,
    );
  }

  void hideLoadingDialog() {
    LoadingDialogManager().hide();
  }

  bool get isLoadingDialogShowing => LoadingDialogManager().isShowing;
}

extension ToastificationExtension on BuildContext {
  void showSnackbar(
    String message, {
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? textColor,
    int? maxLines = 1,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: TextWidget(
          message,
          style: textStyle,
          color: textColor,
          maxLines: maxLines,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showToast(
    String title, {
    String? message,
    ToastificationType type = ToastificationType.success,
    ToastificationStyle style = ToastificationStyle.flat,
    VoidCallback? onTap,
  }) {
    Overlays.showToast(
      title: title,
      context: this,
      message: message,
      type: type,
      onTap: onTap,
      style: style,
    );
  }

  void showToastFromFailure(Failure failure) => showToast(
    failure.title,
    message: failure.message,
    type: ToastificationType.error,
  );
}
