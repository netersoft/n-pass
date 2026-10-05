import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../view/themes/app_colors.dart';
import '../../../view/themes/app_theme.dart';
import '../../services/i18n/translations.g.dart';

abstract class ImageHelper {
  /// Image editing
  /// Dependencies
  /// Image Cropper : https://pub.dev/packages/image_cropper
  static Future<File?> cropImage(
    File image, {
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat imageCompressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
    bool lockAspectRatio = false,
    bool showShopGrid = true,
    CropAspectRatio? aspectRatio,
    int? maxWidth,
    int? maxHeight,
  }) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      compressFormat: imageCompressFormat,
      compressQuality: compressQuality,
      aspectRatio: aspectRatio,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      uiSettings: [
        AndroidUiSettings(
          cropStyle: cropStyle,
          toolbarTitle: t.editPicture,
          toolbarColor: AppTheme.pickColor(
            light: Colors.white,
            dark: AppColors.blackRussian,
          ),
          statusBarLight: AppTheme.isLight(),
          backgroundColor: AppTheme.pickColor(
            light: Colors.white,
            dark: AppColors.blackRussian,
          ),
          toolbarWidgetColor: AppTheme.primaryColor,
          activeControlsWidgetColor: AppTheme.primaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: lockAspectRatio,
          showCropGrid: showShopGrid,
          hideBottomControls: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          cropStyle: cropStyle,
          minimumAspectRatio: 1.0,
          title: t.editPicture,
          doneButtonTitle: t.done,
          cancelButtonTitle: t.cancel,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}
