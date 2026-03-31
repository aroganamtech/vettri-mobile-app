import 'package:flutter/material.dart';
import 'models/social_data.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = SocialData.getMessages()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  void _markRead(int index) {
    setState(() => _messages[index]['unread'] = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Messages',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        itemCount: _messages.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 76),
        itemBuilder: (_, index) => _MessageTile(
          data: _messages[index],
          onOpen: () {
            _markRead(index);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => _ChatScreen(user: _messages[index])),
            );
          },
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onOpen;

  const _MessageTile({required this.data, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final unread = data['unread'] as int;
    final online = data['online'] as bool;

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(data['avatar'] as String),
                  radius: 28,
                ),
                if (online)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] as String,
                      style: TextStyle(
                          fontWeight: unread > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(data['lastMsg'] as String,
                      style: TextStyle(
                          color: unread > 0 ? Colors.black87 : Colors.grey,
                          fontWeight: unread > 0
                              ? FontWeight.w500
                              : FontWeight.normal,
                          fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data['time'] as String,
                    style: TextStyle(
                        color: unread > 0
                            ? Colors.red
                            : Colors.grey,
                        fontSize: 12)),
                const SizedBox(height: 4),
                if (unread > 0)
                  // Red dot badge
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat Screen ──────────────────────────────────────────────────────────────

class _ChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const _ChatScreen({required this.user});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hey! Saw your latest post 🔥', 'isMe': false, 'time': '10:02 AM'},
    {
      'text': 'Thanks! Really happy with how it turned out 😄',
      'isMe': true,
      'time': '10:04 AM'
    },
    {
      'text': 'When is your next Clip coming?',
      'isMe': false,
      'time': '10:05 AM'
    },
    {
      'text': 'Working on it! Should be out by the weekend 🎬',
      'isMe': true,
      'time': '10:07 AM'
    },
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true, 'time': 'now'});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.user['avatar'] as String),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user['name'] as String,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                if (widget.user['online'] as bool)
                  const Text('Online',
                      style:
                          TextStyle(color: Colors.green, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.videocam_outlined, color: Colors.black),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.call_outlined, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg['text'] as String,
                            style: TextStyle(
                                color: isMe
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 14)),
                        const SizedBox(height: 3),
                        Text(msg['time'] as String,
                            style: TextStyle(
                                color: isMe
                                    ? Colors.white70
                                    : Colors.grey,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
