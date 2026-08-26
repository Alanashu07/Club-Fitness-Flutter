import 'package:club_fitness/config/local/db_helper.dart';
import 'package:club_fitness/core/exceptions/app_exception.dart';
import 'package:club_fitness/core/exceptions/status_codes.dart';
import 'package:sqflite/sqflite.dart';

import '../models/image_model.dart';
import 'image_save_isolate.dart';

abstract interface class CacheImageDataSource {
  Future<ImageModel> saveImage(String imageUrl);

  Future<List<ImageModel>> getImages();

  Future<int> deleteImage(String? url);

  Future<int> deleteAllImages();

  Future<int> clearAllCache();

  Future<int> clearOldCache();

  Future<int> updateImage(ImageModel imageModel);

  Future<ImageModel> getImage(String? url);

  Future<void> createImageTable(Database db);
}

class CacheImageDataSourceImpl implements CacheImageDataSource {
  final DBHelper _helper;

  const CacheImageDataSourceImpl(this._helper);

  @override
  Future<int> deleteAllImages() async {
    final db = await _helper.database;
    await createImageTable(db);
    return await db.delete(DBHelper.images);
  }

  @override
  Future<int> deleteImage(String? url) async {
    if (url == null) {
      throw const AppException(
        title: 'NO URL!',
        message: 'No Url is provided!',
        code: 404,
      );
    }
    final db = await _helper.database;
    await createImageTable(db);
    return await db.delete(DBHelper.images, where: 'url = ?', whereArgs: [url]);
  }

  @override
  Future<ImageModel> getImage(String? url) async {
    if (url == null) {
      throw const AppException(
        title: 'NO URL!',
        message: 'No Url is provided!',
        code: 404,
      );
    }
    final db = await _helper.database;
    await createImageTable(db);
    final result = await db.query(
      DBHelper.images,
      where: 'url = ?',
      whereArgs: [url],
    );
    return result.isNotEmpty
        ? ImageModel.fromJson(result.first)
        : await saveImage(url);
  }

  @override
  Future<List<ImageModel>> getImages() async {
    final db = await _helper.database;
    await createImageTable(db);
    final result = await db.query(DBHelper.images);
    return result.map((e) => ImageModel.fromJson(e)).toList();
  }

  Future<String?> checkFailedImage(String url) async {
    final db = await _helper.database;
    await createImageTable(db);
    final result = await db.query(
      DBHelper.failedImages,
      where: 'url = ?',
      whereArgs: [url],
    );
    if (result.isEmpty) return null;
    return result.first['error'] as String?;
  }

  @override
  Future<ImageModel> saveImage(String? url) async {
    if (url == null) {
      throw const AppException(
        title: 'NO URL!',
        message: 'No Url is provided!',
        code: 404,
      );
    }
    // final response = await DioConfig().dioGetMedia(url);
    // if (response.hasError) {
    //   final data = response.dioError.response?.data;
    //   if (data == null) {
    //     throw StatusCodes.errorFromStatusCode(
    //         response.dioError.response?.statusCode ?? StatusCodes.unknownError);
    //   }
    // }
    // final directory = await getApplicationDocumentsDirectory();
    // int now = DateTime.now().millisecondsSinceEpoch;
    // String fileName = now.toString();
    //
    // // Define the file path where the image will be saved
    // final filePath = '${directory.path}/$fileName';
    //
    // // Check if the file already exists
    // final file = File(filePath);
    //
    // // Download the image
    // await file.writeAsBytes(Uint8List.fromList(response.response!.data));
    final db = await _helper.database;
    await createImageTable(db);

    final failedImage = await checkFailedImage(url);
    if (failedImage != null) {
      throw AppException(
        title: 'Image Failed once',
        message: failedImage,
        code: StatusCodes.conflict,
      );
    }

    final saveResult = await ImageSaveIsolate.downloadImage(url);
    if (saveResult == null) {
      return ImageModel(
        url: url,
        filePath: '',
        timeStamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
    if (!saveResult.success) {
      await db.insert(DBHelper.failedImages, {
        'url': url,
        'error': saveResult.error,
        'time_stamp': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      throw AppException(
        title: 'Image Error for url: $url',
        message: saveResult.error ?? '',
        code: StatusCodes.conflict,
      );
    }
    if (url != saveResult.url) {
      throw AppException(
        title: 'Image Error for url: $url',
        message:
            'URL Mismatch detected. Original: $url, Downloaded: ${saveResult.url}',
        code: StatusCodes.conflict,
      );
    }
    final imageModel = ImageModel(
      url: url,
      timeStamp: saveResult.timestamp,
      filePath: saveResult.filePath,
    );
    final id = await db.insert(
      DBHelper.images,
      imageModel.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return imageModel.copyWith(id: id);
  }

  @override
  Future<int> updateImage(ImageModel imageModel) async {
    final db = await _helper.database;
    await createImageTable(db);
    return await db.update(
      DBHelper.images,
      imageModel.toJson(),
      where: 'id = ?',
      whereArgs: [imageModel.id],
    );
  }

  @override
  Future<void> createImageTable(Database db) async {
    await _helper.createTable(
      db: db,
      tableName: DBHelper.images,
      columns: {
        'id': 'INTEGER PRIMARY KEY AUTOINCREMENT',
        'url': 'TEXT UNIQUE',
        'file_path': 'TEXT UNIQUE',
        'time_stamp': 'INTEGER',
      },
    );
    await _helper.createTable(
      db: db,
      tableName: DBHelper.failedImages,
      columns: {
        'id': 'INTEGER PRIMARY KEY AUTOINCREMENT',
        'url': 'TEXT UNIQUE',
        'error': 'TEXT',
        'time_stamp': 'INTEGER',
      },
    );
  }

  @override
  Future<int> clearAllCache() async {
    int count = 0;
    // final tempDir = await getTemporaryDirectory();
    // final dir = Directory(tempDir.path);
    // if (!await dir.exists()) return 0;
    // final files = dir.listSync();
    // count = files.length;
    // dir.listSync().forEach((element) => element.deleteSync(recursive: true));
    final images = await getImages();
    for (var image in images) {
      bool result = await ImageSaveIsolate.deleteImage(image);
      if (result) {
        int deleted = await deleteImage(image.url);
        count += deleted;
      }
    }
    return count;
  }

  @override
  Future<int> clearOldCache() async {
    final images = await getImages();
    int count = 0;
    num days = 30;
    final now = DateTime.now();
    for (var image in images) {
      final diff = now.difference(
        DateTime.fromMillisecondsSinceEpoch(image.timeStamp.toInt()),
      );
      if (diff.inDays < days) continue;
      bool result = await ImageSaveIsolate.deleteImage(image);
      if (result) {
        int deleted = await deleteImage(image.url);
        count += deleted;
      }
    }
    return count;
  }
}
