import 'package:flutter/material.dart';
import '../widgets/upload_sheet.dart';

class StoryCircle extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isOwn;

  const StoryCircle({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isOwn,
  });

  @override
  State<StoryCircle> createState() => _StoryCircleState();
}

class _StoryCircleState extends State<StoryCircle> {
  bool _seen = false;

  void _handleTap(BuildContext context) {
    if (widget.isOwn) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),
              const Text('Your Story',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.grey[100], shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Colors.black),
                ),
                title: const Text('Add to Story',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Share a photo, video or text'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const UploadSheet(initialType: 'Story'),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: Colors.grey[100], shape: BoxShape.circle),
                  child: const Icon(Icons.remove_red_eye_outlined,
                      color: Colors.black),
                ),
                title: const Text('View My Story',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("See what you've shared"),
                onTap: () {
                  Navigator.pop(context);
                  _openStoryViewer(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    } else {
      _openStoryViewer(context);
    }
  }

  void _openStoryViewer(BuildContext context) {
    setState(() => _seen = true);
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _StoryViewerScreen(
          name: widget.name,
          avatarUrl: widget.avatarUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Column(
        children: [
          Stack(
            children: [
              // ── Ring: orange gradient when unseen, grey when seen ──
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _seen
                      ? LinearGradient(
                          colors: [Colors.grey[400]!, Colors.grey[400]!],
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFFFF8C00), // dark orange
                            Color(0xFFFF5722), // deep orange
                            Color(0xFFFFC107), // amber
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.avatarUrl),
                    radius: 28,
                  ),
                ),
              ),
              if (widget.isOwn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 66,
            child: Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Full-screen Story Viewer ─────────────────────────────────────────────────

class _StoryViewerScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;

  const _StoryViewerScreen({
    required this.name,
    required this.avatarUrl,
  });

  @override
  State<_StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<_StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  final List<String> _storySeeds = ['story1', 'story2', 'story3'];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _progressController.forward();
  }

  void _nextStory() {
    if (_currentIndex < _storySeeds.length - 1) {
      setState(() => _currentIndex++);
      _progressController.reset();
      _progressController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final x = details.globalPosition.dx;
          if (x < size.width / 2) {
            _prevStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story image
            Image.network(
              'https://picsum.photos/seed/${_storySeeds[_currentIndex]}/600/1000',
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const Center(
                    child:
                        CircularProgressIndicator(color: Colors.white));
              },
            ),

            // Dark top gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),

            // Top bar: progress + user info + close
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  // Progress bars
                  Row(
                    children: List.generate(_storySeeds.length, (i) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: i < _currentIndex
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )
                              : i == _currentIndex
                                  ? AnimatedBuilder(
                                      animation: _progressController,
                                      builder: (_, __) =>
                                          FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            _progressController.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // User info row
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.avatarUrl),
                        radius: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      const Text('• 2h ago',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom reply bar
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.white60, width: 1.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.centerLeft,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Reply...',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.send_outlined,
                      color: Colors.white, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
