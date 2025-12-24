import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../widgets/feed_post_card.dart';
import 'comments_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<FeedPost> _posts = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

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

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _posts.addAll(_getMockPosts());
      _isLoading = false;
    });
  }

  Future<void> _refreshPosts() async {
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _posts.clear();
      _posts.addAll(_getMockPosts());
      _isRefreshing = false;
    });
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading) return;
    // Load more logic
  }

  void _addPost(String content, {List<String>? tags}) {
    setState(() {
      _posts.insert(
        0,
        FeedPost(
          id: DateTime.now().toString(),
          userId: 'current_user_id',
          username: 'You',
          content: content,
          createdAt: DateTime.now(),
          tags: tags ?? [],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _isLoading && _posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
                'Campus Feed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xFF94A3B8)),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),

            // Posts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == _posts.length) {
                    return _isLoading
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : const SizedBox.shrink();
                  }

                  return FeedPostCard(
                    post: _posts[index],
                    onLike: () => _likePost(index),
                    onComment: () => _openComments(_posts[index]),
                    onShare: () => _sharePost(_posts[index]),
                    onBookmark: () => _bookmarkPost(index),
                    onUserTap: () => _openUserProfile(_posts[index].userId),
                  );
                },
                childCount: _posts.length + 1,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        backgroundColor: const Color(0xFF2B6CEE),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('All', isSelected: true),
          _buildChip('Following'),
          _buildChip('Trending'),
          _buildChip('Events'),
          _buildChip('Jobs'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Filter logic
        },
        backgroundColor: const Color(0xFF1E293B),
        selectedColor: const Color(0xFF2B6CEE),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF2B6CEE)
              : Colors.white.withValues(alpha:0.1),
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
              Icons.article_outlined,
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
          const Text(
            'Be the first to share something!',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openCreatePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B6CEE),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  void _openCreatePost() {
    final contentController = TextEditingController();
    final tagsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Create Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (contentController.text.trim().isEmpty) return;

                      final tags = tagsController.text
                          .split(',')
                          .map((tag) => tag.trim())
                          .where((tag) => tag.isNotEmpty)
                          .toList();

                      _addPost(contentController.text.trim(), tags: tags);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6CEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content input
              Expanded(
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "What's happening on campus?",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tags input
              TextField(
                controller: tagsController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add tags (comma separated)',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.tag, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Media options
              Row(
                children: [
                  _buildMediaOption(Icons.image_outlined, 'Image'),
                  const SizedBox(width: 12),
                  _buildMediaOption(Icons.link, 'Link'),
                  const SizedBox(width: 12),
                  _buildMediaOption(Icons.poll_outlined, 'Poll'),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaOption(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // Handle media option
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha:0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _likePost(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        likes: post.isLikedByCurrentUser ? post.likes - 1 : post.likes + 1,
        isLikedByCurrentUser: !post.isLikedByCurrentUser,
      );
    });
  }

  void _bookmarkPost(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isBookmarked: !post.isBookmarked,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _posts[index].isBookmarked ? 'Post saved' : 'Post removed',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _sharePost(FeedPost post) {
    // Share logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openComments(FeedPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(post: post),
      ),
    );
  }

  void _openUserProfile(String userId) {
    // Navigate to user profile
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Filter Posts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.whatshot, color: Color(0xFF94A3B8)),
                title: const Text('Trending', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: Color(0xFF94A3B8)),
                title: const Text('Recent', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Color(0xFF94A3B8)),
                title: const Text('Most Liked', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  List<FeedPost> _getMockPosts() {
    return [
      FeedPost(
        id: '1',
        userId: 'user1',
        username: 'Akhil Kumar',
        userDepartment: 'Computer Science',
        content: 'Just finished our team\'s hackathon project! Built an AI-powered campus assistant. Super excited about the results! 🚀',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        likes: 24,
        comments: 5,
        tags: ['hackathon', 'AI', 'tech'],
        type: PostType.text,
      ),
      FeedPost(
        id: '2',
        userId: 'user2',
        username: 'Priya Sharma',
        userDepartment: 'Business Administration',
        content: 'Anyone interested in starting a book club? Would love to discuss "Atomic Habits" and other self-improvement books!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        comments: 8,
        tags: ['books', 'community'],
        type: PostType.text,
      ),
      FeedPost(
        id: '3',
        userId: 'user3',
        username: 'Rahul Verma',
        userDepartment: 'Mechanical Engineering',
        content: 'Check out our robotics team\'s latest project! We built an autonomous navigation system.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 45,
        comments: 12,
        shares: 3,
        tags: ['robotics', 'engineering', 'innovation'],
        type: PostType.image,
        imageUrls: [
          'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=500',
        ],
      ),
      FeedPost(
        id: '4',
        userId: 'user4',
        username: 'Sneha Patel',
        userDepartment: 'Design',
        content: 'UI/UX workshop this Saturday! Learn about design thinking and prototype your ideas. Limited spots available!',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likes: 31,
        comments: 15,
        tags: ['workshop', 'design', 'UIUX'],
        type: PostType.event,
      ),
    ];
  }
}

