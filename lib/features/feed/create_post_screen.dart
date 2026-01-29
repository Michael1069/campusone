import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/post_service.dart';
import '../../core/services/cloudinary_image_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final PostService _postService = PostService();
  final CloudinaryImageService _imageService = CloudinaryImageService();
  
  bool _isPosting = false;
  List<File> _selectedImages = [];
  int _uploadProgress = 0;
  int _totalImages = 0;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imageService.pickMultipleImages(maxImages: 5);
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or add photos!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    List<String> imageUrls = [];

    // Upload images if any
    if (_selectedImages.isNotEmpty) {
      imageUrls = await _imageService.uploadMultipleImages(
        _selectedImages,
        onProgress: (current, total) {
          setState(() {
            _uploadProgress = current;
            _totalImages = total;
          });
        },
      );
    }

    // Create post
    final postId = await _postService.createPost(
      content: _contentController.text.trim(),
      imageUrls: imageUrls,
    );

    setState(() => _isPosting = false);

    if (mounted) {
      if (postId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Post created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create post. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isPosting ? null : _createPost,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF2B6CEE),
                disabledBackgroundColor: const Color(0xFF2B6CEE).withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2B6CEE),
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? Text(
                          currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.displayName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Content input
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 4,
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
            
            // Selected images preview
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Upload progress
            if (_isPosting && _totalImages > 0) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploading images... $_uploadProgress/$_totalImages',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _uploadProgress / _totalImages,
                    backgroundColor: const Color(0xFF1E293B),
                    color: const Color(0xFF2B6CEE),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Actions row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  _buildActionButton(
                    Icons.image_outlined,
                    'Photo',
                    _pickImages,
                    enabled: !_isPosting,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    Icons.tag_outlined,
                    'Tag',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tagging coming soon!'),
                        ),
                      );
                    },
                    enabled: false,
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    Icons.location_on_outlined,
                    'Location',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location coming soon!'),
                        ),
                      );
                    },
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool enabled = true,
  }) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? const Color(0xFF2B6CEE) : const Color(0xFF475569),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
