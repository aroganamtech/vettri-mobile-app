import 'package:flutter/material.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({super.key, required this.postId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _comments = [
    {'user': 'Ravi Kumar', 'avatar': 'https://i.pravatar.cc/150?img=30', 'text': 'Absolutely stunning! 😍', 'time': '1h', 'likes': 12, 'isLiked': false},
    {'user': 'Sowmya', 'avatar': 'https://i.pravatar.cc/150?img=47', 'text': 'Where is this place?? 🤩', 'time': '2h', 'likes': 8, 'isLiked': false},
    {'user': 'Arun_V', 'avatar': 'https://i.pravatar.cc/150?img=52', 'text': 'Amazing shot! 📸', 'time': '3h', 'likes': 5, 'isLiked': true},
    {'user': 'Nithya', 'avatar': 'https://i.pravatar.cc/150?img=45', 'text': 'Love this! ❤️', 'time': '5h', 'likes': 3, 'isLiked': false},
  ];

  void _addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'user': 'You',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'text': text,
        'time': 'now',
        'likes': 0,
        'isLiked': false,
      });
    });
    _controller.clear();
  }

  void _toggleCommentLike(int index) {
    setState(() {
      final c = _comments[index];
      final liked = c['isLiked'] as bool;
      _comments[index] = {
        ...c,
        'isLiked': !liked,
        'likes': (c['likes'] as int) + (liked ? -1 : 1),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            // Comments List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _comments.length,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                itemBuilder: (_, index) {
                  final c = _comments[index];
                  final isLiked = c['isLiked'] as bool;
                  final likes = c['likes'] as int;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(c['avatar'] as String),
                          radius: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username on its own line
                              Text(
                                c['user'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 3),
                              // Comment text below username
                              Text(
                                c['text'] as String,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    c['time'] as String,
                                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                                  ),
                                  const SizedBox(width: 14),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text('Reply',
                                        style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Like button
                        GestureDetector(
                          onTap: () => _toggleCommentLike(index),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                if (likes > 0)
                                  Text(
                                    '$likes',
                                    style: TextStyle(
                                      color: isLiked ? Colors.red : Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Input Box
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addComment,
                    child: Icon(Icons.send_rounded, color: Theme.of(context).primaryColor, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
