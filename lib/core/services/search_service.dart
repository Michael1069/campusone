import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../models/feed_post.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Search users/profiles
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final searchQuery = query.toLowerCase().trim();
      
      // Search by name (case-insensitive)
      final nameResults = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: searchQuery + 'z')
          .limit(20)
          .get();

      // Search by username
      final usernameResults = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchQuery)
          .where('username', isLessThan: searchQuery + 'z')
          .limit(20)
          .get();

      // Combine and deduplicate results
      final Map<String, UserModel> userMap = {};

      for (var doc in [...nameResults.docs, ...usernameResults.docs]) {
        if (!userMap.containsKey(doc.id)) {
          final data = doc.data();
          userMap[doc.id] = UserModel(
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
        }
      }

      return userMap.values.toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Search posts
  Future<List<FeedPost>> searchPosts(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final searchQuery = query.toLowerCase().trim();

      // Firestore doesn't support full-text search, so we'll do a simple content search
      // For production, consider using Algolia or ElasticSearch
      final results = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      // Filter results client-side
      final posts = results.docs.where((doc) {
        final data = doc.data();
        final content = (data['content'] ?? '').toString().toLowerCase();
        final username = (data['username'] ?? '').toString().toLowerCase();
        return content.contains(searchQuery) || username.contains(searchQuery);
      }).map((doc) {
        final data = doc.data();
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

      return posts.take(20).toList();
    } catch (e) {
      print('Error searching posts: $e');
      return [];
    }
  }

  // Search clubs (placeholder for now)
  Future<List<Map<String, dynamic>>> searchClubs(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      // TODO: Implement clubs search when clubs feature is added
      return [];
    } catch (e) {
      print('Error searching clubs: $e');
      return [];
    }
  }
}
