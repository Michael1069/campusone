import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/feed_post.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/time_formatter.dart';
import '../../core/services/user_service.dart';
import '../../core/services/follow_service.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final FollowService _followService = FollowService();
  
  UserModel? _user;
  List<FeedPost> _userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    // Load user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      _user = UserModel(
        id: userDoc.id,
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

      // Load user's posts
      _userPosts = await _userService.getUserPosts(widget.userId, limit: 20);

      // Check if following
      _isFollowing = await _followService.isFollowing(widget.userId);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _isFollowLoading = true);

    bool success;
    if (_isFollowing) {
      success = await _followService.unfollowUser(widget.userId);
    } else {
      success = await _followService.followUser(widget.userId);
    }

    if (success && mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
        if (_user != null) {
          _user = _user!.copyWith(
            followersCount: _isFollowing
                ? _user!.followersCount + 1
                : _user!.followersCount - 1,
          );
        }
        _isFollowLoading = false;
      });
    } else {
      setState(() => _isFollowLoading = false);
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

    if (_user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'User not found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _user!.username ?? _user!.name,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          _buildUserInfo(),
          _buildFollowButton(),
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
          const SizedBox(height: 16),
          UserAvatar(
            imageUrl: _user!.avatarUrl,
            name: _user!.name,
            size: 100,
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_user!.username != null) ...[
            const SizedBox(height: 4),
            Text(
              '@${_user!.username}',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
              ),
            ),
          ],
          if (_user!.department != null || _user!.year != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_user!.department != null) ...[
                  const Icon(Icons.school, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    _user!.department!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                ],
                if (_user!.department != null && _user!.year != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                  ),
                if (_user!.year != null)
                  Text(
                    _user!.year!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
          if (_user!.bio != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _user!.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (_user!.interests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _user!.interests.take(5).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2B6CEE).withOpacity(0.3),
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
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton(
          onPressed: _isFollowLoading ? null : _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFollowing
                ? const Color(0xFF1E293B)
                : const Color(0xFF2B6CEE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: _isFollowing
                  ? const BorderSide(color: Color(0xFF94A3B8), width: 1)
                  : BorderSide.none,
            ),
          ),
          child: _isFollowLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
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
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Posts', _user!.postsCount.toString()),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.1),
            ),
            _buildStatItem(
              'Followers',
              TimeFormatter.formatCompactNumber(_user!.followersCount),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.1),
            ),
            _buildStatItem(
              'Following',
              TimeFormatter.formatCompactNumber(_user!.followingCount),
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
          labelColor: const Color(0xFF2B6CEE),
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
            Tab(icon: Icon(Icons.info_outline), text: 'About'),
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
          _buildPostsGrid(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    if (_userPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 60, color: Color(0xFF94A3B8)),
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

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        final hasImages = post.imageUrls.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasImages
                ? Image.network(
                    post.imageUrls.first,
                    fit: BoxFit.cover,
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            post.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_user!.skills.isNotEmpty) ...[
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
            children: _user!.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
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
        _buildInfoRow(Icons.email, _user!.email),
        if (_user!.lastActive != null)
          _buildInfoRow(
            Icons.access_time,
            'Active ${TimeFormatter.getRelativeTime(_user!.lastActive!)}',
          ),
        _buildInfoRow(
          Icons.cake,
          'Joined ${TimeFormatter.getRelativeTime(_user!.createdAt)}',
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
            color: Colors.white.withOpacity(0.05),
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
