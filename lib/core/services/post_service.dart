import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/feed_post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new post
  Future<String?> createPost({
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      if (_currentUserId == null) throw Exception('User not authenticated');

      final user = _auth.currentUser!;
      final postId = _firestore.collection('posts').doc().id;

      final postData = {
        'id': postId,
        'userId': _currentUserId,
        'username': user.displayName ?? 'Unknown User',
        'userAvatar': user.photoURL,
        'content': content,
        'imageUrls': imageUrls ?? [],
        'likes': 0,
        'comments': 0,
        'shares': 0,
        'likedBy': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('posts').doc(postId).set(postData);

      // Update user's post count
      await _firestore.collection('users').doc(_currentUserId).update({
        'postsCount': FieldValue.increment(1),
      });

      return postId;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get feed posts (paginated)
  Future<List<FeedPost>> getFeedPosts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        
        return FeedPost(
          id: data['id'] ?? doc.id,
          userId: data['userId'] ?? '',
          username: data['username'] ?? 'Unknown',
          userAvatar: data['userAvatar'],
          content: data['content'] ?? '',
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          shares: data['shares'] ?? 0,
          isLikedByCurrentUser: _currentUserId != null && likedBy.contains(_currentUserId),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Like/Unlike a post
  Future<bool> toggleLike(String postId, bool isCurrentlyLiked) async {
    try {
      if (_currentUserId == null) return false;

      final postRef = _firestore.collection('posts').doc(postId);

      if (isCurrentlyLiked) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([_currentUserId]),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([_currentUserId]),
        });
      }

      return true;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      if (_currentUserId == null) return false;

      // Verify ownership
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists || doc.data()?['userId'] != _currentUserId) {
        return false;
      }

      // Delete post
      await _firestore.collection('posts').doc(postId).delete();

      // Update user's post count
      await _firestore.collection('users').doc(_currentUserId).update({
        'postsCount': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Save/Unsave a post (bookmark)
  Future<bool> toggleSave(String postId, bool isCurrentlySaved) async {
    try {
      if (_currentUserId == null) return false;

      final userRef = _firestore.collection('users').doc(_currentUserId);

      if (isCurrentlySaved) {
        // Unsave
        await userRef.update({
          'savedPosts': FieldValue.arrayRemove([postId]),
        });
      } else {
        // Save
        await userRef.update({
          'savedPosts': FieldValue.arrayUnion([postId]),
        });
      }

      return true;
    } catch (e) {
      print('Error toggling save: $e');
      return false;
    }
  }

  // Get saved posts for current user
  Future<List<FeedPost>> getSavedPosts() async {
    try {
      if (_currentUserId == null) return [];

      // Get user's saved post IDs
      final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
      final savedPostIds = List<String>.from(userDoc.data()?['savedPosts'] ?? []);

      if (savedPostIds.isEmpty) return [];

      // Fetch saved posts (in batches if needed)
      final posts = <FeedPost>[];
      
      // Firestore 'in' query supports max 10 items, so batch them
      for (int i = 0; i < savedPostIds.length; i += 10) {
        final batch = savedPostIds.skip(i).take(10).toList();
        
        final snapshot = await _firestore
            .collection('posts')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final likedBy = List<String>.from(data['likedBy'] ?? []);
          
          posts.add(FeedPost(
            id: data['id'] ?? doc.id,
            userId: data['userId'] ?? '',
            username: data['username'] ?? 'Unknown',
            userAvatar: data['userAvatar'],
            content: data['content'] ?? '',
            imageUrls: List<String>.from(data['imageUrls'] ?? []),
            likes: data['likes'] ?? 0,
            comments: data['comments'] ?? 0,
            shares: data['shares'] ?? 0,
            isLikedByCurrentUser: likedBy.contains(_currentUserId),
            isBookmarked: true, // All these posts are saved
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ));
        }
      }

      // Sort by most recent
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    } catch (e) {
      print('Error fetching saved posts: $e');
      return [];
    }
  }

  // Check if a post is saved by current user
  Future<bool> isPostSaved(String postId) async {
    try {
      if (_currentUserId == null) return false;

      final userDoc = await _firestore.collection('users').doc(_currentUserId).get();
      final savedPostIds = List<String>.from(userDoc.data()?['savedPosts'] ?? []);
      
      return savedPostIds.contains(postId);
    } catch (e) {
      print('Error checking if post is saved: $e');
      return false;
    }
  }
}
