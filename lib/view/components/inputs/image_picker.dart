import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<XFile> selectedImages;
  final VoidCallback onAddImages;
  final Function(XFile) onRemoveImage;

  const ImagePickerWidget({
    required this.selectedImages,
    required this.onAddImages,
    required this.onRemoveImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectedImages
            .map(
              (file) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    child: Image.file(
                      File(file.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 5,
                    child: GestureDetector(
                      onTap: () {
                        onRemoveImage(file);
                      },
                      child: const Icon(
                        Icons.cancel,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        icon: const Icon(Icons.add_photo_alternate),
        label: Text(
          context.t.addImage,
          style: const TextStyle(fontSize: 12),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.getIconColor(),
          side: BorderSide(color: AppTheme.getIconColor()),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        onPressed: onAddImages,
      ),
    ],
  );
}
