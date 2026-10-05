import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

import '../../helpers/logging/log_helper.dart';
import '../../tools/functions/file_functions.dart';
import '../../tools/functions/random_functions.dart';

abstract class MediaCompressService {
  static const String _successTag = 'Media Compress Success : ';
  static const String _errorTag = 'Media Compress Error : ';

  static Future<File?> compressImageAsset(
    String assetName, {
    int minWidth = 640,
    int minHeight = 480,
    int quality = 90,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
  }) async {
    try {
      Uint8List? list = await FlutterImageCompress.compressAssetImage(
        assetName,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle: autoCorrectionAngle,
        format: format,
        keepExif: keepExif,
      );

      return await _getFileFromUint8list(list);
    } catch (e) {
      LogHelper.e('$_errorTag $e');
    }

    return null;
  }

  static Future<File?> compressImageFromPath(
    String filePath,
    String resultPath, {
    int minWidth = 640,
    int minHeight = 480,
    int inSampleSize = 1,
    int quality = 90,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
  }) async {
    try {
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        resultPath,
        inSampleSize: inSampleSize,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle: autoCorrectionAngle,
        format: format,
        keepExif: keepExif,
      );

      if (result != null) {
        LogHelper.i('$_successTag ${result.path}');

        return File(result.path);
      } else {
        LogHelper.e('$_errorTag bytes list is null');
      }
    } catch (e) {
      LogHelper.e('$_errorTag $e');
    }

    return null;
  }

  static Future<File?> compressImageList(
    Uint8List list, {
    int minWidth = 640,
    int minHeight = 480,
    int quality = 90,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
  }) async {
    try {
      Uint8List l = await FlutterImageCompress.compressWithList(
        list,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle: autoCorrectionAngle,
        format: format,
        keepExif: keepExif,
      );

      return await _getFileFromUint8list(l);
    } catch (e) {
      LogHelper.e('$_errorTag $e');
    }

    return null;
  }

  static Future<File?> compressImageFile(
    File file, {
    int minWidth = 640,
    int minHeight = 480,
    int inSampleSize = 1,
    int quality = 90,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = true,
  }) async {
    try {
      Uint8List? list = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minHeight: minHeight,
        minWidth: minWidth,
        quality: quality,
        rotate: rotate,
        autoCorrectionAngle: autoCorrectionAngle,
        format: format,
        keepExif: keepExif,
      );

      return await _getFileFromUint8list(list);
    } catch (e) {
      LogHelper.e('$_errorTag $e');
    }

    return null;
  }

  static Future<File?> _getFileFromUint8list(Uint8List? list) async {
    if (list != null) {
      final tempDir = await getTemporaryDirectory();
      final result = await File(
        '${tempDir.path}/${genRandomAlphaNumeric(13)}.jpg',
      ).create();
      result.writeAsBytesSync(list);

      LogHelper.i('$_successTag ${result.path}');

      return result;
    }

    LogHelper.e('$_errorTag bytes list is null');

    return null;
  }

  static Future<File?> compressVideo(String path) async {
    Subscription? subscription;
    try {
      final fileSize = getFileSize(File(path), 2);
      VideoQuality? videoQuality;

      subscription = VideoCompress.compressProgress$.subscribe((progress) {
        LogHelper.d('Video Compress Method B Progress : $progress');
      });

      LogHelper.d('Video Compress Method B : Input File Size $fileSize');

      switch (fileSize.split(' ')[1]) {
        case 'MB':
          double size = double.parse(fileSize.split(' ')[0]);
          if (size > 0 && size <= 3) {
            videoQuality = VideoQuality.HighestQuality;
          } else if (size > 3 && size <= 5) {
            videoQuality = VideoQuality.MediumQuality;
          } else if (size > 5 && size <= 10) {
            videoQuality = VideoQuality.DefaultQuality;
          } else if (size > 10 && size <= 20) {
            videoQuality = VideoQuality.LowQuality;
          } else {
            videoQuality = VideoQuality.LowQuality;
          }

        case 'GB':
          videoQuality = VideoQuality.HighestQuality;
      }

      if (videoQuality == null) return File(path);

      final stopwatchB = Stopwatch()..start();

      await VideoCompress.compressVideo(
        path,
        quality: videoQuality,
      );

      LogHelper.d('Video Compress Method B executed in ${stopwatchB.elapsed}');
    } catch (e) {
      LogHelper.e('$_errorTag Video Compress Method B : $e');
    }

    if (subscription != null) subscription.unsubscribe();

    return null;
  }

  static Future<void> cancelVideoCompressing() async {
    await VideoCompress.cancelCompression();
  }
}
