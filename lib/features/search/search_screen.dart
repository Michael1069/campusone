import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/feed_post.dart';
import '../../core/services/search_service.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/feed_post_card.dart';
import '../../utils/time_formatter.dart';
import '../feed/comments_screen.dart';
import '../profile/user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  
  bool _isSearching = false;
  List<UserModel> _userResults = [];
  List<FeedPost> _postResults = [];
  List<Map<String, dynamic>> _clubResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _userResults = [];
        _postResults = [];
        _clubResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    // Search all categories
    final users = await _searchService.searchUsers(query);
    final posts = await _searchService.searchPosts(query);
    final clubs = await _searchService.searchClubs(query);

    if (mounted) {
      setState(() {
        _userResults = users;
        _postResults = posts;
        _clubResults = clubs;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _performSearch(query);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search profiles, posts, clubs...',
                  hintStyle: const TextStyle(
                    color: Color(0x80FFFFFF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x1AFFFFFF),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF2B6CEE),
                indicatorWeight: 3,
                labelColor: const Color(0xFF2B6CEE),
                unselectedLabelColor: const Color(0xFF94A3B8),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'Profiles (${_userResults.length})'),
                  Tab(text: 'Posts (${_postResults.length})'),
                  Tab(text: 'Clubs (${_clubResults.length})'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfilesTab(),
                  _buildPostsTab(),
                  _buildClubsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesTab() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search,
        title: 'Search for people',
        subtitle: 'Find students by name, username, or department',
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2B6CEE),
        ),
      );
    }

    if (_userResults.isEmpty) {
      return _buildNoResults('No profiles found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: UserAvatar(
              imageUrl: user.avatarUrl,
              name: user.name,
              size: 48,
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.username != null)
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                if (user.department != null)
                  Text(
                    user.department!,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(userId: user.id),
                  ),
                );
              },
              child: const Text('View'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        title: 'Search posts',
        subtitle: 'Find posts by content or tags',
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2B6CEE),
        ),
      );
    }

    if (_postResults.isEmpty) {
      return _buildNoResults('No posts found');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _postResults.length,
      itemBuilder: (context, index) {
        final post = _postResults[index];
        return FeedPostCard(
          post: post,
          onLike: () {
            // TODO: Implement like
          },
          onComment: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentsScreen(post: post),
              ),
            );
          },
          onShare: () {
            // TODO: Implement share
          },
        );
      },
    );
  }

  Widget _buildClubsTab() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.groups_outlined,
        title: 'Search clubs',
        subtitle: 'Find clubs and communities',
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2B6CEE),
        ),
      );
    }

    return _buildEmptyState(
      icon: Icons.groups_outlined,
      title: 'Clubs coming soon',
      subtitle: 'Club search will be available once clubs feature is added',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B),
              border: Border.all(
                color: const Color(0x1AFFFFFF),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 48,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0x99FFFFFF),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term',
            style: TextStyle(
              color: Color(0x99FFFFFF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
