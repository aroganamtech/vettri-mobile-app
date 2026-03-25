import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'comment_sheet.dart';

class ReelCard extends StatefulWidget {
  final PostModel reel;

  const ReelCard({super.key, required this.reel});

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  late bool _isLiked;
  late int _likeCount;
  bool _isPlaying = true;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.reel.isLiked;
    _likeCount = widget.reel.likes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;

    // Full bottom safe area: nav bar height + system gesture inset
    final navBarHeight = kBottomNavigationBarHeight + mq.padding.bottom;
    // Extra breathing room so content clears the nav bar visually
    const extraPad = 24.0;
    final captionBottom = navBarHeight + extraPad;
    // Action buttons sit above the caption block (~130 px tall)
    final actionsBottom = captionBottom + 140.0;

    return GestureDetector(
      onTap: () => setState(() => _isPlaying = !_isPlaying),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background thumbnail ──────────────────────────────────────
          if (widget.reel.imageUrl != null)
            Image.network(
              widget.reel.imageUrl!,
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Container(color: Colors.black);
              },
            ),

          // ── Dark gradient — heavier at the very bottom ────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black45,
                  Colors.black87,
                ],
                stops: [0.0, 0.4, 0.72, 1.0],
              ),
            ),
          ),

          // ── Play / Pause icon ─────────────────────────────────────────
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow_rounded,
                  color: Colors.white70, size: 80),
            ),

          // ── Right-side action buttons ─────────────────────────────────
          Positioned(
            right: 12,
            bottom: actionsBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ReelActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _formatCount(_likeCount),
                  color: _isLiked ? Colors.red : Colors.white,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 20),
                _ReelActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: _formatCount(widget.reel.comments),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CommentSheet(postId: widget.reel.id),
                  ),
                ),
                const SizedBox(height: 20),
                _ReelActionButton(
                  icon: Icons.send_outlined,
                  label: _formatCount(widget.reel.shares),
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _ReelActionButton(
                    icon: Icons.more_vert, label: '', onTap: () {}),
                const SizedBox(height: 20),
                _SpinningDisc(avatarUrl: widget.reel.userAvatar),
              ],
            ),
          ),

          // ── Bottom caption block — pinned just above nav bar ──────────
          Positioned(
            left: 12,
            right: 80,
            bottom: captionBottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.reel.userAvatar),
                      radius: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.reel.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _isJoined = !_isJoined),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isJoined
                              ? Colors.white24
                              : Colors.transparent,
                          border:
                              Border.all(color: Colors.white, width: 1.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isJoined ? 'Joined ✓' : 'JoinX',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Caption
                Text(
                  widget.reel.caption,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Audio row
                const Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Original Audio',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ReelActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ReelActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

// ─── Spinning disc ────────────────────────────────────────────────────────────

class _SpinningDisc extends StatefulWidget {
  final String avatarUrl;
  const _SpinningDisc({required this.avatarUrl});

  @override
  State<_SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<_SpinningDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          image: DecorationImage(
            image: NetworkImage(widget.avatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
