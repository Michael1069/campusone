import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/feed_post.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/time_formatter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/user_service.dart';
import '../../core/services/post_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  UserModel? _currentUser;
  List<FeedPost> _userPosts = [];
  List<FeedPost> _savedPosts = [];
  bool _isLoading = true;
  bool _isLoadingSaved = false;
  bool _isLoadingMorePosts = false;
  bool _hasMorePosts = true;
  DocumentSnapshot? _lastPostDocument;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Load saved posts when Saved tab is selected
    if (_tabController.index == 1 && _savedPosts.isEmpty && !_isLoadingSaved) {
      _loadSavedPosts();
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    // Load user data from Firebase
    final user = await _userService.getCurrentUser();
    
    if (user != null) {
      // Load user's posts (first page)
      final posts = await _userService.getUserPosts(user.id, limit: 20);
      
      // Get last document for pagination
      if (posts.isNotEmpty) {
        _lastPostDocument = await _userService.getLastPostDocument(user.id, posts.length);
      }
      
      if (mounted) {
        setState(() {
          _currentUser = user;
          _userPosts = posts;
          _hasMorePosts = posts.length >= 20; // If we got 20, there might be more
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMorePosts || !_hasMorePosts || _currentUser == null) return;

    setState(() => _isLoadingMorePosts = true);

    try {
      final morePosts = await _userService.getUserPosts(
        _currentUser!.id,
        limit: 20,
        lastDocument: _lastPostDocument,
      );

      if (morePosts.isNotEmpty) {
        _lastPostDocument = await _userService.getLastPostDocument(
          _currentUser!.id,
          _userPosts.length + morePosts.length,
        );
      }

      if (mounted) {
        setState(() {
          _userPosts.addAll(morePosts);
          _hasMorePosts = morePosts.length >= 20;
          _isLoadingMorePosts = false;
        });
      }
    } catch (e) {
      print('Error loading more posts: $e');
      if (mounted) {
        setState(() => _isLoadingMorePosts = false);
      }
    }
  }

  Future<void> _loadSavedPosts() async {
    setState(() => _isLoadingSaved = true);

    final posts = await _postService.getSavedPosts();

    if (mounted) {
      setState(() {
        _savedPosts = posts;
        _isLoadingSaved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2B6CEE),
          ),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B6CEE),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // Simple app bar with only settings button
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            toolbarHeight: 56,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: _showSettings,
              ),
            ],
          ),
          _buildUserInfo(),
          _buildStats(),
          _buildTabBar(),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF0F172A),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: UserAvatar(
              imageUrl: _currentUser!.avatarUrl,
              name: _currentUser!.name,
              size: 100,
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            _currentUser!.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Username
          if (_currentUser!.username != null)
            Text(
              '@${_currentUser!.username}',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
              ),
            ),
          const SizedBox(height: 8),

          // Department & Year
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentUser!.department != null) ...[
                const Icon(
                  Icons.school,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  _currentUser!.department!,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
              ],
              if (_currentUser!.department != null && _currentUser!.year != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              if (_currentUser!.year != null)
                Text(
                  _currentUser!.year!,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
            ],
          ),

          // Bio
          if (_currentUser!.bio != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _currentUser!.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Interests
          if (_currentUser!.interests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _currentUser!.interests.take(5).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2B6CEE).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      interest,
                      style: const TextStyle(
                        color: Color(0xFF60A5FA),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _editProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6CEE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _shareProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.share),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Posts',
              _currentUser!.postsCount.toString(),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            _buildStatItem(
              'Followers',
              TimeFormatter.formatCompactNumber(_currentUser!.followersCount),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            _buildStatItem(
              'Following',
              TimeFormatter.formatCompactNumber(_currentUser!.followingCount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2B6CEE),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: const Color(0xFF2B6CEE),
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.grid_on, size: 22),
              text: 'Posts',
            ),
            Tab(
              icon: Icon(Icons.bookmark_border, size: 22),
              text: 'Saved',
            ),
            Tab(
              icon: Icon(Icons.info_outline, size: 22),
              text: 'About',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildSavedTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_userPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _userPosts.length,
            itemBuilder: (context, index) {
              final post = _userPosts[index];
              return _buildPostCard(post);
            },
          ),
        ),
        // Load More Button
        if (_hasMorePosts)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _isLoadingMorePosts
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2B6CEE),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _loadMorePosts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Load More Posts',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildSavedTab() {
    if (_isLoadingSaved) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2B6CEE),
        ),
      );
    }

    if (_savedPosts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSavedPosts,
        color: const Color(0xFF2B6CEE),
        backgroundColor: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 60,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved posts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Save posts to view them here',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedPosts,
      color: const Color(0xFF2B6CEE),
      backgroundColor: const Color(0xFF1E293B),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _savedPosts.length,
        itemBuilder: (context, index) {
          final post = _savedPosts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    // Check if post has images
    final hasImages = post.imageUrls.isNotEmpty;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: hasImages
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    post.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF0F172A),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Color(0xFF94A3B8),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likes.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        post.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Color(0xFFEC4899),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likes.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.chat_bubble,
                            size: 14,
                            color: Color(0xFF60A5FA),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.comments.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_currentUser!.skills.isNotEmpty) ...[
          const Text(
            'Skills',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _currentUser!.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        _buildInfoRow(Icons.email, _currentUser!.email),
        if (_currentUser!.lastActive != null)
          _buildInfoRow(
            Icons.access_time,
            'Active ${TimeFormatter.getRelativeTime(_currentUser!.lastActive!)}',
          ),
        _buildInfoRow(
          Icons.cake,
          'Joined ${TimeFormatter.getRelativeTime(_currentUser!.createdAt)}',
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Profile editing coming soon!',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile link copied to clipboard!'),
        backgroundColor: Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSettings() {
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
              ListTile(
                leading: const Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                title: const Text('Account Settings', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined, color: Color(0xFF94A3B8)),
                title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF94A3B8)),
                title: const Text('Privacy', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final auth = context.read<AuthProvider>();
              auth.logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
