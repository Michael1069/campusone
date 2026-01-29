import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../widgets/feed_post_card.dart';
import '../../core/services/post_service.dart';
import 'comments_screen.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();
  
  List<FeedPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    final posts = await _postService.getFeedPosts(limit: 20);
    
    // Load bookmark status for each post
    for (var i = 0; i < posts.length; i++) {
      final isSaved = await _postService.isPostSaved(posts[i].id);
      posts[i] = posts[i].copyWith(isBookmarked: isSaved);
    }

    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    final posts = await _postService.getFeedPosts(limit: 20);
    
    // Load bookmark status for each post
    for (var i = 0; i < posts.length; i++) {
      final isSaved = await _postService.isPostSaved(posts[i].id);
      posts[i] = posts[i].copyWith(isBookmarked: isSaved);
    }

    if (mounted) {
      setState(() {
        _posts = posts;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;
    // TODO: Implement pagination with lastDocument
  }

  Future<void> _toggleLike(FeedPost post) async {
    // Optimistic update
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          likes: post.isLikedByCurrentUser ? post.likes - 1 : post.likes + 1,
          isLikedByCurrentUser: !post.isLikedByCurrentUser,
        );
      }
    });

    // Update in Firebase
    await _postService.toggleLike(post.id, post.isLikedByCurrentUser);
  }

  Future<void> _toggleSave(FeedPost post) async {
    // Optimistic update
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isBookmarked: !post.isBookmarked,
        );
      }
    });

    // Update in Firebase
    final success = await _postService.toggleSave(post.id, post.isBookmarked);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              post.isBookmarked ? 'Post removed from saved' : 'Post saved!',
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );

    if (result == true) {
      _refreshPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading && _posts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2B6CEE),
              ),
            )
          : _posts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refreshPosts,
                  color: const Color(0xFF2B6CEE),
                  backgroundColor: const Color(0xFF1E293B),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        backgroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        title: const Text(
                          'Feed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF2B6CEE),
                            ),
                            onPressed: _navigateToCreatePost,
                          ),
                        ],
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = _posts[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: FeedPostCard(
                                  post: post,
                                  onLike: () => _toggleLike(post),
                                  onComment: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CommentsScreen(
                                          post: post,
                                        ),
                                      ),
                                    );
                                    // Refresh feed to show updated comment count
                                    _refreshPosts();
                                  },
                                  onShare: () {
                                    // TODO: Implement share
                                  },
                                  onBookmark: () => _toggleSave(post),
                                ),
                              );
                            },
                            childCount: _posts.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B),
              border: Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.post_add,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No posts yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreatePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B6CEE),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Post',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
