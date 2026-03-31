import 'package:flutter/material.dart';
import '../../core/widgets/bottom_navbar.dart';
import 'models/post_model.dart';
import 'models/social_data.dart';
import 'models/user_model.dart';
import 'widgets/post_card.dart';
import 'widgets/reel_card.dart';
import 'widgets/story_circle.dart';
import 'widgets/upload_sheet.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'messages_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<PostModel> _posts;
  late List<PostModel> _clips;
  final PageController _clipPageController = PageController();

  bool _hasUnseenNotifications = true;
  bool _hasUnseenMessages = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _posts = SocialData.getPosts();
    _clips = SocialData.getClips();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _currentTab) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clipPageController.dispose();
    super.dispose();
  }

  void _openUpload() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UploadSheet(),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ProfileScreen(user: kCurrentUser, isOwnProfile: true),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openNotifications() {
    setState(() => _hasUnseenNotifications = false);
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  void _openMessages() {
    setState(() => _hasUnseenMessages = false);
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const MessagesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Colors.white,
            floating: true,
            snap: true,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // ── Profile avatar — plain circle, NO story ring ──
                GestureDetector(
                  onTap: _openProfile,
                  child: const CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=1'),
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Vettri Social',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            actions: [
              // Search
              IconButton(
                icon:
                    const Icon(Icons.search, color: Colors.black, size: 27),
                onPressed: _openSearch,
                tooltip: 'Search users',
              ),

              // Notifications with red dot
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.black, size: 27),
                    onPressed: _openNotifications,
                  ),
                  if (_hasUnseenNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),

              // Messages with red dot
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Colors.black, size: 25),
                    onPressed: _openMessages,
                    tooltip: 'Messages',
                  ),
                  if (_hasUnseenMessages)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Clips'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(),
            _buildClipsTab(),
          ],
        ),
      ),
      // FAB only visible on Posts tab (index 0)
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: _openUpload,
              backgroundColor: Theme.of(context).primaryColor,
              tooltip: 'Create Post',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildPostsTab() {
    final stories = SocialData.getStories();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _posts = SocialData.getPosts());
      },
      child: ListView(
        children: [
          // Stories section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: stories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final s = stories[index];
                  return StoryCircle(
                    name: s['name']!,
                    avatarUrl: s['avatar']!,
                    isOwn: s['isOwn'] == 'true',
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._posts.map((post) => PostCard(post: post)).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildClipsTab() {
    return PageView.builder(
      controller: _clipPageController,
      scrollDirection: Axis.vertical,
      itemCount: _clips.length,
      itemBuilder: (_, index) => ReelCard(reel: _clips[index]),
    );
  }
}
