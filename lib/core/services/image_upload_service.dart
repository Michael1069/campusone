import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  // Upload single image to Firebase Storage
  Future<String?> uploadImage(File imageFile, {String folder = 'posts'}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('❌ User not authenticated');
        return null;
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('$folder/$userId/$fileName');

      print('📤 Uploading image: $fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Image uploaded: $downloadUrl');
        return downloadUrl;
      }

      return null;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple images to Firebase Storage
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

  // Delete image from Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Image deleted: $imageUrl');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }
}
