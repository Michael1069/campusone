import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../models/feed_post.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      if (_currentUserId == null) return null;

      final doc = await _firestore.collection('users').doc(_currentUserId).get();
      
      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserModel(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        username: data['username'],
        avatarUrl: data['avatarUrl'],
        bio: data['bio'],
        department: data['department'],
        year: data['year'],
        interests: List<String>.from(data['interests'] ?? []),
        skills: List<String>.from(data['skills'] ?? []),
        followersCount: data['followersCount'] ?? 0,
        followingCount: data['followingCount'] ?? 0,
        postsCount: data['postsCount'] ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Get user's posts with pagination
  Future<List<FeedPost>> getUserPosts(
    String userId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
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
      print('Error getting user posts: $e');
      return [];
    }
  }

  // Get the last document snapshot for pagination
  Future<DocumentSnapshot?> getLastPostDocument(
    String userId,
    int skipCount,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(skipCount)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.last;
    } catch (e) {
      print('Error getting last document: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? department,
    String? year,
    List<String>? interests,
    List<String>? skills,
  }) async {
    try {
      if (_currentUserId == null) return false;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (department != null) updates['department'] = department;
      if (year != null) updates['year'] = year;
      if (interests != null) updates['interests'] = interests;
      if (skills != null) updates['skills'] = skills;

      await _firestore.collection('users').doc(_currentUserId).update(updates);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
