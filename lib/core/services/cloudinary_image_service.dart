import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryImageService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'djfuwsnv0', // Your cloud name
    'campusone_posts', // Upload preset
    cache: false,
  );
  
  final ImagePicker _picker = ImagePicker();

  // Pick single image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.length > maxImages) {
        print('⚠️ Too many images selected. Max: $maxImages');
        return images.take(maxImages).map((xFile) => File(xFile.path)).toList();
      }

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Upload single image to Cloudinary
  Future<String?> uploadImage(File imageFile, {String folder = 'posts'}) async {
    try {
      print('📤 Uploading image to Cloudinary...');
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      print('✅ Image uploaded: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles, {
    String folder = 'posts',
    Function(int current, int total)? onProgress,
  }) async {
    final List<String> downloadUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      onProgress?.call(i + 1, imageFiles.length);
      
      final url = await uploadImage(imageFiles[i], folder: folder);
      if (url != null) {
        downloadUrls.add(url);
      }
    }

    return downloadUrls;
  }
}
