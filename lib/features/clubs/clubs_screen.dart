import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../widgets/user_avatar.dart';
import '../../utils/time_formatter.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Club> _allClubs = [];
  final List<Club> _myClubs = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Technical',
    'Sports',
    'Arts',
    'Academic',
    'Social',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClubs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _allClubs.addAll(_getMockClubs());
      _myClubs.addAll(_allClubs.where((club) => club.isCurrentUserMember).toList());
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              title: const Text(
                'Clubs & Communities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF2B6CEE),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF94A3B8),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: 'Discover'),
                  Tab(text: 'My Clubs'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDiscoverTab(),
            _buildMyClubsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateClubDialog,
        backgroundColor: const Color(0xFF2B6CEE),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Club',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredClubs = _selectedCategory == 'All'
        ? _allClubs
        : _allClubs.where((club) => club.category == _selectedCategory).toList();

    return Column(
      children: [
        // Category filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
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
            },
          ),
        ),

        // Clubs list
        Expanded(
          child: filteredClubs.isEmpty
              ? _buildEmptyState('No clubs found in this category')
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredClubs.length,
            itemBuilder: (context, index) {
              return _buildClubCard(filteredClubs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyClubsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myClubs.isEmpty) {
      return _buildEmptyState(
        'You haven\'t joined any clubs yet',
        subtitle: 'Explore clubs and join communities that interest you!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _myClubs.length,
      itemBuilder: (context, index) {
        return _buildClubCard(_myClubs[index], showJoinButton: false);
      },
    );
  }

  Widget _buildClubCard(Club club, {bool showJoinButton = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          if (club.bannerUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                club.bannerUrl!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2B6CEE).withValues(alpha:0.3),
                        const Color(0xFF8B5CF6).withValues(alpha:0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (club.avatarUrl != null)
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(club.avatarUrl!),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 3,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2B6CEE).withValues(alpha:0.7),
                              const Color(0xFF8B5CF6).withValues(alpha:0.7),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            club.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B6CEE).withValues(alpha:0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  club.category,
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.people,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                TimeFormatter.formatCompactNumber(club.membersCount),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showJoinButton)
                      ElevatedButton(
                        onPressed: () => _toggleJoinClub(club),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: club.isCurrentUserMember
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF2B6CEE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: club.isCurrentUserMember
                                ? BorderSide(
                              color: Colors.white.withValues(alpha:0.2),
                            )
                                : BorderSide.none,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          club.isCurrentUserMember ? 'Joined' : 'Join',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  club.description,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (club.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: club.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha:0.1),
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (club.upcomingEvents.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 16,
                          color: Color(0xFF2B6CEE),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Next event: ${club.upcomingEvents.first.title}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, {String? subtitle}) {
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
              Icons.groups_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleJoinClub(Club club) {
    setState(() {
      final index = _allClubs.indexWhere((c) => c.id == club.id);
      if (index != -1) {
        final updatedClub = _allClubs[index].copyWith(
          isCurrentUserMember: !_allClubs[index].isCurrentUserMember,
          membersCount: _allClubs[index].isCurrentUserMember
              ? _allClubs[index].membersCount - 1
              : _allClubs[index].membersCount + 1,
        );
        _allClubs[index] = updatedClub;

        if (updatedClub.isCurrentUserMember) {
          _myClubs.add(updatedClub);
        } else {
          _myClubs.removeWhere((c) => c.id == club.id);
        }
      }
    });
  }

  void _showCreateClubDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Create New Club',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Club creation feature coming soon! Contact your campus administrator to create a new club.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF2B6CEE)),
            ),
          ),
        ],
      ),
    );
  }

  List<Club> _getMockClubs() {
    return [
      Club(
        id: '1',
        name: 'Tech Innovators',
        description: 'Building the future through technology. Join us for hackathons, workshops, and tech talks.',
        category: 'Technical',
        tags: ['coding', 'AI', 'hackathons'],
        membersCount: 234,
        isCurrentUserMember: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        upcomingEvents: [
          ClubEvent(
            id: 'e1',
            clubId: '1',
            title: 'AI Workshop',
            description: 'Learn about machine learning basics',
            startTime: DateTime.now().add(const Duration(days: 3)),
            attendeesCount: 45,
          ),
        ],
      ),
      Club(
        id: '2',
        name: 'Basketball League',
        description: 'Competitive basketball team representing our campus in inter-college tournaments.',
        category: 'Sports',
        tags: ['basketball', 'fitness', 'competition'],
        membersCount: 156,
        isCurrentUserMember: false,
        createdAt: DateTime.now().subtract(const Duration(days: 240)),
      ),
      Club(
        id: '3',
        name: 'Debate Society',
        description: 'Sharpen your critical thinking and public speaking skills through structured debates.',
        category: 'Academic',
        tags: ['debate', 'public-speaking', 'critical-thinking'],
        membersCount: 89,
        isCurrentUserMember: false,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Club(
        id: '4',
        name: 'Art & Design Collective',
        description: 'A community for artists, designers, and creative minds to collaborate and showcase their work.',
        category: 'Arts',
        tags: ['art', 'design', 'creativity'],
        membersCount: 201,
        isCurrentUserMember: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        upcomingEvents: [
          ClubEvent(
            id: 'e2',
            clubId: '4',
            title: 'Annual Art Exhibition',
            description: 'Showcase your artwork',
            startTime: DateTime.now().add(const Duration(days: 7)),
            attendeesCount: 78,
          ),
        ],
      ),
      Club(
        id: '5',
        name: 'Entrepreneurship Cell',
        description: 'For aspiring entrepreneurs. Learn about startups, business strategy, and innovation.',
        category: 'Academic',
        tags: ['startups', 'business', 'innovation'],
        membersCount: 312,
        isCurrentUserMember: false,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
    ];
  }
}