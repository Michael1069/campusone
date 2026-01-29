import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../utils/time_formatter.dart';
import 'user_avatar.dart';

class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onUserTap;

  const FeedPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onShare,
    this.onBookmark,
    this.onUserTap,
  });

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  bool _isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLike();
    setState(() => _isLikeAnimating = true);
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
      setState(() => _isLikeAnimating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: UserAvatar(
                    imageUrl: widget.post.userAvatar,
                    name: widget.post.username,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onUserTap,
                        child: Text(
                          widget.post.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        TimeFormatter.getRelativeTime(widget.post.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
                  onPressed: () => _showPostOptions(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Images (show before content)
          if (widget.post.imageUrls.isNotEmpty) _buildImageDisplay(),

          // Content
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: widget.post.isLikedByCurrentUser
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: widget.post.likes > 0
                      ? TimeFormatter.formatCompactNumber(widget.post.likes)
                      : '',
                  color: widget.post.isLikedByCurrentUser
                      ? const Color(0xFFEC4899)
                      : const Color(0xFF94A3B8),
                  onTap: _handleLike,
                  isAnimating: _isLikeAnimating,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: widget.post.comments > 0
                      ? TimeFormatter.formatCompactNumber(widget.post.comments)
                      : '',
                  color: const Color(0xFF94A3B8),
                  onTap: widget.onComment,
                ),
                const SizedBox(width: 8),
                if (widget.onShare != null)
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: widget.post.shares > 0
                        ? TimeFormatter.formatCompactNumber(widget.post.shares)
                        : '',
                    color: const Color(0xFF94A3B8),
                    onTap: widget.onShare!,
                  ),
                const Spacer(),
                if (widget.onBookmark != null)
                  _buildActionButton(
                    icon: widget.post.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: '',
                    color: widget.post.isBookmarked
                        ? const Color(0xFF2B6CEE)
                        : const Color(0xFF94A3B8),
                    onTap: widget.onBookmark!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isAnimating = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isAnimating ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: 22, color: color),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    final images = widget.post.imageUrls;
    
    if (images.length == 1) {
      // Single image - show full without cropping
      return Image.network(
        images[0],
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 300,
            color: const Color(0xFF0F172A),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF2B6CEE),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 300,
          color: const Color(0xFF0F172A),
          child: const Center(
            child: Icon(Icons.broken_image, color: Color(0xFF94A3B8), size: 48),
          ),
        ),
      );
    }
    
    // Multiple images - grid layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: images.length == 2 ? 2 : 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: images.length > 4 ? 4 : images.length,
      itemBuilder: (context, index) {
        final isLast = index == 3 && images.length > 4;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0F172A),
                child: const Icon(Icons.broken_image, color: Color(0xFF94A3B8)),
              ),
            ),
            if (isLast)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Text(
                    '+${images.length - 4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showPostOptions(BuildContext context) {
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
              _buildBottomSheetOption(
                icon: Icons.link,
                label: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);
                  // Copy link logic
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.report_outlined,
                label: 'Report Post',
                onTap: () {
                  Navigator.pop(context);
                  // Report logic
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF94A3B8),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
