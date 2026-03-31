import 'package:flutter/material.dart';
import 'models/social_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    // Load notifications — items with isNew=true show a red dot
    _notifications = SocialData.getNotifications()
        .map((n) => Map<String, dynamic>.from(n))
        .toList();
  }

  void _markAllSeen() {
    setState(() {
      for (final n in _notifications) {
        n['isNew'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final newItems = _notifications.where((n) => n['isNew'] as bool).toList();
    final earlierItems =
        _notifications.where((n) => !(n['isNew'] as bool)).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          if (newItems.isNotEmpty)
            TextButton(
              onPressed: _markAllSeen,
              child: const Text('Mark all read',
                  style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (newItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text('New',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ...newItems.map((n) => _NotificationTile(
                  data: n,
                  onSeen: () => setState(() => n['isNew'] = false),
                )),
          ],
          if (earlierItems.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text('Earlier',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ...earlierItems.map((n) => _NotificationTile(data: n)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onSeen;

  const _NotificationTile({required this.data, this.onSeen});

  IconData _iconForType(String type) {
    switch (type) {
      case 'join':
        return Icons.person_add;
      case 'members':
        return Icons.group;
      case 'trending':
        return Icons.local_fire_department;
      case 'like':
        return Icons.favorite;
      case 'joined':
        return Icons.how_to_reg;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'join':
        return Colors.blue;
      case 'members':
        return Colors.purple;
      case 'trending':
        return Colors.orange;
      case 'like':
        return Colors.red;
      case 'joined':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = data['isNew'] as bool;
    final type = data['type'] as String;

    return GestureDetector(
      onTap: onSeen,
      child: Container(
        color: isNew ? Colors.orange.withOpacity(0.06) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(data['avatar'] as String),
                  radius: 24,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _colorForType(type),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child:
                        Icon(_iconForType(type), color: Colors.white, size: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['text'] as String,
                      style: TextStyle(
                          fontWeight: isNew
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(data['sub'] as String,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(data['time'] as String,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            // Red dot for unseen
            if (isNew)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
