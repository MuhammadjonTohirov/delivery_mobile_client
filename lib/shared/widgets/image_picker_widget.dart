import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../extensions/extensions.dart';

class ImagePickerWidget extends StatelessWidget {
  final Function(XFile) onImageSelected;
  final String? title;
  final String? subtitle;
  final bool showCameraOption;
  final bool showGalleryOption;
  final double? imageQuality; // 0.0 to 1.0
  final int? maxWidth;
  final int? maxHeight;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.title,
    this.subtitle,
    this.showCameraOption = true,
    this.showGalleryOption = true,
    this.imageQuality = 0.8,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          AppSpacing.v16,
          
          // Title and subtitle
          if (title != null) ...[
            title!.h4.weight(FontWeight.bold),
            AppSpacing.v8,
          ],
          if (subtitle != null) ...[
            subtitle!.bodyMedium.color(Colors.grey[600]!),
            AppSpacing.v16,
          ],
          
          // Options
          [
            if (showCameraOption)
              _buildOptionTile(
                context,
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Use camera to take a new photo',
                onTap: () => _pickImage(context, ImageSource.camera),
              ),
            
            if (showGalleryOption)
              _buildOptionTile(
                context,
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select from your photo gallery',
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
          ].asColumn(spacing: AppSpacing.sm),
          
          AppSpacing.v16,
          
          // Cancel button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.o10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      // Check and request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isDenied) {
          _showPermissionDialog(context, 'Camera');
          return;
        }
      } else {
        final photoStatus = await Permission.photos.request();
        if (photoStatus.isDenied) {
          _showPermissionDialog(context, 'Photo Library');
          return;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        // Remove imageQuality, maxWidth, maxHeight to prevent any processing
        preferredCameraDevice: source == ImageSource.camera ? CameraDevice.front : CameraDevice.rear,
      );

      if (image != null) {
        // Validate image size (max 5MB)
        final file = File(image.path);
        final fileSize = await file.length();
        const maxSize = 5 * 1024 * 1024; // 5MB in bytes

        if (fileSize > maxSize) {
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Image Too Large',
              'Please select an image smaller than 5MB.',
            );
          }
          return;
        }

        // Validate image format
        final extension = image.name.toLowerCase().split('.').last;
        const allowedFormats = ['jpg', 'jpeg', 'png'];
        
        if (!allowedFormats.contains(extension)) {
          if (context.mounted) {
            _showErrorDialog(
              context,
              'Invalid Format',
              'Please select a JPG, PNG, or WebP image.',
            );
          }
          return;
        }

        onImageSelected(image);
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          'Error',
          'Failed to pick image: ${e.toString()}',
        );
      }
    }
  }

  void _showPermissionDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('This feature requires access to your $permission. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Settings', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  // Static method to show image picker bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(XFile) onImageSelected,
    String? title,
    String? subtitle,
    bool showCameraOption = true,
    bool showGalleryOption = true,
    double? imageQuality = 0.8,
    int? maxWidth,
    int? maxHeight,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: ImagePickerWidget(
          onImageSelected: onImageSelected,
          title: title,
          subtitle: subtitle,
          showCameraOption: showCameraOption,
          showGalleryOption: showGalleryOption,
          imageQuality: imageQuality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
      ),
    );
  }
}