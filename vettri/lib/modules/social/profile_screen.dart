import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'widgets/upload_sheet.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isOwnProfile;

  const ProfileScreen({
    super.key,
    required this.user,
    this.isOwnProfile = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isJoined;
  late int _members;

  // Editable fields (live state)
  late String _name;
  late String _bio;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isJoined  = widget.user.isJoined;
    _members   = widget.user.members;
    _name      = widget.user.name;
    _bio       = widget.user.bio;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleJoin() {
    setState(() {
      _isJoined = !_isJoined;
      _members += _isJoined ? 1 : -1;
    });
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000)    return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  // ── Edit Profile bottom sheet ──────────────────────────────────────────────
  void _openEditProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final bioCtrl  = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Edit Profile',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Text('Name',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bio',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: bioCtrl,
                maxLines: 3,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Tell people about yourself…',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    final newBio  = bioCtrl.text.trim();
                    Navigator.pop(ctx);
                    setState(() {
                      if (newName.isNotEmpty) _name = newName;
                      if (newBio.isNotEmpty)  _bio  = newBio;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            expandedHeight: 0,
            leading: widget.isOwnProfile
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
            title: Text(
              widget.user.username,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            actions: [
              if (widget.isOwnProfile)
                IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {}),
            ],
          ),
        ],
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Profile Header Card ───────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar with ORANGE gradient ring (same as story circles)
                        // + edit pencil that opens the edit sheet
                        Stack(
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C00), // dark orange
                                    Color(0xFFFF5722), // deep orange
                                    Color(0xFFFFC107), // amber
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(widget.user.avatar),
                                  radius: 38,
                                ),
                              ),
                            ),
                            // Pencil button — tapping it opens the edit sheet
                            if (widget.isOwnProfile)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _openEditProfile,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Stats
                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _StatColumn(
                                  label: 'Clips',
                                  value: _formatCount(
                                      widget.user.clips)),
                              _StatColumn(
                                  label: 'Members',
                                  value: _formatCount(_members)),
                              _StatColumn(
                                  label: 'Joined',
                                  value: _formatCount(
                                      widget.user.joined)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(_name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(_bio,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13.5)),
                    const SizedBox(height: 16),

                    // Action buttons
                    if (widget.isOwnProfile)
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileButton(
                              label: 'Edit Profile',
                              onTap: _openEditProfile,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileButton(
                              label: 'Share Profile',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          _ProfileButton(
                            label: '',
                            icon: Icons.person_add_outlined,
                            onTap: () {},
                            isIcon: true,
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _toggleJoin,
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _isJoined
                                      ? Colors.grey[200]
                                      : Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _isJoined ? 'Joined ✓' : 'JoinX',
                                  style: TextStyle(
                                    color: _isJoined
                                        ? Colors.black87
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileButton(
                                label: 'Message', onTap: () {}),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),

              // ── Content tabs ──────────────────────────────────────────
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.play_circle_outline)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                  ],
                ),
              ),

              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGrid('posts'),
                    _buildGrid('clips'),
                    _buildGrid('saved'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(String type) {
    final seeds = type == 'clips'
        ? ['reel1', 'reel2', 'reel3']
        : type == 'saved'
            ? ['save1', 'save2', 'save3', 'save4']
            : ['post1', 'post2', 'post3', 'post4', 'post5', 'post6'];

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: seeds.length,
      itemBuilder: (_, index) => Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://picsum.photos/seed/${seeds[index]}/300/300',
            fit: BoxFit.cover,
          ),
          if (type == 'clips')
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isIcon;

  const _ProfileButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: isIcon
            ? const EdgeInsets.symmetric(horizontal: 12)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: isIcon
            ? Icon(icon, size: 20)
            : Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
