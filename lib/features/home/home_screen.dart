import 'package:flutter/material.dart';
import '../feed/feed_screen.dart';
import '../clubs/clubs_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedScreen(),
    ClubsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF2B6CEE),
            unselectedItemColor: const Color(0xFF94A3B8),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home, size: 24),
                ),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.groups_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.groups, size: 24),
                ),
                label: 'Clubs',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person, size: 24),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
