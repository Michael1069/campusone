import 'package:flutter/material.dart';
import '../feed/feed_screen.dart';
import '../search/search_screen.dart';
import '../clubs/clubs_screen.dart';
import '../profile/profile_screen.dart';

class HomeShellNew extends StatefulWidget {
  const HomeShellNew({super.key});

  @override
  State<HomeShellNew> createState() => _HomeShellNewState();
}

class _HomeShellNewState extends State<HomeShellNew> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    ClubsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: const Color(0xFF2B6CEE),
        unselectedItemColor: const Color(0xFF94A3B8),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
