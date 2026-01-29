import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Add a comment
  Future<String?> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    try {
      if (_currentUserId == null) {
        print('❌ Error: User not authenticated');
        throw Exception('User not authenticated');
      }

      final user = _auth.currentUser!;
      final commentId = _firestore.collection('comments').doc().id;

      print('📝 Adding comment...');
      print('   Post ID: $postId');
      print('   User: ${user.displayName} (${user.email})');
      print('   Content: $content');

      final commentData = {
        'id': commentId,
        'postId': postId,
        'userId': _currentUserId,
        'username': user.displayName ?? 'Unknown User',
        'userAvatar': user.photoURL,
        'content': content,
        'parentId': parentId,
        'likes': 0,
        'likedBy': <String>[],
        'replies': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('comments').doc(commentId).set(commentData);
      print('✅ Comment added to Firestore');

      // Update post comment count
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });
      print('✅ Post comment count updated');

      // If it's a reply, update parent comment reply count
      if (parentId != null) {
        await _firestore.collection('comments').doc(parentId).update({
          'replies': FieldValue.increment(1),
        });
        print('✅ Parent comment reply count updated');
      }

      print('✅ Comment created successfully: $commentId');
      return commentId;
    } catch (e) {
      print('❌ Error adding comment: $e');
      return null;
    }
  }

  // Get comments for a post
  Future<List<Comment>> getComments(String postId) async {
    try {
      // Get top-level comments
      final snapshot = await _firestore
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .where('parentId', isNull: true)
          .orderBy('createdAt', descending: false)
          .get();

      final comments = <Comment>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final commentId = data['id'] ?? doc.id;
        
        // Get replies for this comment
        final repliesSnapshot = await _firestore
            .collection('comments')
            .where('parentId', isEqualTo: commentId)
            .orderBy('createdAt', descending: false)
            .get();

        final replies = repliesSnapshot.docs.map((replyDoc) {
          final replyData = replyDoc.data();
          return Comment(
            id: replyData['id'] ?? replyDoc.id,
            postId: replyData['postId'] ?? '',
            userId: replyData['userId'] ?? '',
            username: replyData['username'] ?? 'Unknown',
            userAvatar: replyData['userAvatar'],
            content: replyData['content'] ?? '',
            parentCommentId: replyData['parentId'],
            likes: replyData['likes'] ?? 0,
            isLikedByCurrentUser: (replyData['likedBy'] as List?)?.contains(_currentUserId) ?? false,
            createdAt: (replyData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();

        comments.add(Comment(
          id: commentId,
          postId: data['postId'] ?? '',
          userId: data['userId'] ?? '',
          username: data['username'] ?? 'Unknown',
          userAvatar: data['userAvatar'],
          content: data['content'] ?? '',
          parentCommentId: data['parentId'],
          likes: data['likes'] ?? 0,
          isLikedByCurrentUser: (data['likedBy'] as List?)?.contains(_currentUserId) ?? false,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          replies: replies,
        ));
      }

      return comments;
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  // Toggle like on a comment
  Future<bool> toggleLike(String commentId, bool isCurrentlyLiked) async {
    try {
      if (_currentUserId == null) return false;

      final commentRef = _firestore.collection('comments').doc(commentId);

      if (isCurrentlyLiked) {
        // Unlike
        await commentRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([_currentUserId]),
        });
      } else {
        // Like
        await commentRef.update({
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
}
