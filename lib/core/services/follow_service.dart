import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Follow a user
  Future<bool> followUser(String targetUserId) async {
    try {
      if (_currentUserId == null || _currentUserId == targetUserId) {
        return false;
      }

      final batch = _firestore.batch();

      // Add to current user's following list
      final currentUserRef = _firestore.collection('users').doc(_currentUserId);
      batch.set(currentUserRef, {
        'following': FieldValue.arrayUnion([targetUserId]),
        'followingCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      // Add to target user's followers list
      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      batch.set(targetUserRef, {
        'followers': FieldValue.arrayUnion([_currentUserId]),
        'followersCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  // Unfollow a user
  Future<bool> unfollowUser(String targetUserId) async {
    try {
      if (_currentUserId == null || _currentUserId == targetUserId) {
        return false;
      }

      final batch = _firestore.batch();

      // Remove from current user's following list
      final currentUserRef = _firestore.collection('users').doc(_currentUserId);
      batch.set(currentUserRef, {
        'following': FieldValue.arrayRemove([targetUserId]),
        'followingCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));

      // Remove from target user's followers list
      final targetUserRef = _firestore.collection('users').doc(targetUserId);
      batch.set(targetUserRef, {
        'followers': FieldValue.arrayRemove([_currentUserId]),
        'followersCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));

      await batch.commit();
      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  // Check if current user is following a specific user
  Future<bool> isFollowing(String targetUserId) async {
    try {
      if (_currentUserId == null) return false;

      final doc = await _firestore.collection('users').doc(_currentUserId).get();
      if (!doc.exists) return false;

      final following = List<String>.from(doc.data()?['following'] ?? []);
      return following.contains(targetUserId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  // Get followers list for a user
  Future<List<String>> getFollowers(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return [];

      return List<String>.from(doc.data()?['followers'] ?? []);
    } catch (e) {
      print('Error getting followers: $e');
      return [];
    }
  }

  // Get following list for a user
  Future<List<String>> getFollowing(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return [];

      return List<String>.from(doc.data()?['following'] ?? []);
    } catch (e) {
      print('Error getting following: $e');
      return [];
    }
  }
}
