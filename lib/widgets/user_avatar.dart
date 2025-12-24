import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: imageUrl == null
                ? LinearGradient(
              colors: [
                _getColorFromName(name).withOpacity(0.7),
                _getColorFromName(name),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            border: Border.all(
              color: const Color(0xFF1E293B),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(),
            )
                : _buildInitials(),
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B),
                border: Border.all(
                  color: const Color(0xFF0F172A),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = name.trim().split(' ').map((word) {
      return word.isNotEmpty ? word[0].toUpperCase() : '';
    }).take(2).join();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colors = [
      const Color(0xFF2B6CEE),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF06B6D4),
    ];

    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    return colors[hash % colors.length];
  }
}