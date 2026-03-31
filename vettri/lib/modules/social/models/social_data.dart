import 'package:flutter/material.dart';
import '../models/post_model.dart';

class SocialData {
  static List<PostModel> getPosts() {
    return [
      PostModel(
        id: 'p1',
        userName: 'Arjun Sharma',
        userAvatar: 'https://i.pravatar.cc/150?img=11',
        imageUrl: 'https://picsum.photos/seed/post1/600/600',
        caption: '🌄 Beautiful sunrise this morning! Nature never fails to amaze me. #sunrise #nature #morning',
        likes: 1240,
        comments: 89,
        shares: 34,
        isLiked: false,
        isReel: false,
        timeAgo: '2h ago',
      ),
      PostModel(
        id: 'p2',
        userName: 'Priya Nair',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        imageUrl: 'https://picsum.photos/seed/post2/600/600',
        caption: '🍜 Trying out new recipes at home. This ramen turned out amazing! #foodie #cooking #homemade',
        likes: 876,
        comments: 45,
        shares: 12,
        isLiked: true,
        isReel: false,
        timeAgo: '4h ago',
      ),
      PostModel(
        id: 'p3',
        userName: 'Karthik Dev',
        userAvatar: 'https://i.pravatar.cc/150?img=15',
        imageUrl: 'https://picsum.photos/seed/post3/600/700',
        caption: '💻 Just shipped a new feature to production! Late nights are totally worth it. #developer #coding #flutter',
        likes: 2100,
        comments: 134,
        shares: 67,
        isLiked: false,
        isReel: false,
        timeAgo: '6h ago',
      ),
      PostModel(
        id: 'p4',
        userName: 'Meera Krishnan',
        userAvatar: 'https://i.pravatar.cc/150?img=9',
        imageUrl: 'https://picsum.photos/seed/post4/600/600',
        caption: '🏖️ Weekend getaway to Pondicherry was a dream! #travel #pondicherry #weekendvibes',
        likes: 3456,
        comments: 210,
        shares: 98,
        isLiked: true,
        isReel: false,
        timeAgo: '1d ago',
      ),
    ];
  }

  static List<PostModel> getClips() {
    return [
      PostModel(
        id: 'r1',
        userName: 'Dance_With_Divya',
        userAvatar: 'https://i.pravatar.cc/150?img=20',
        videoUrl: 'clip_placeholder',
        imageUrl: 'https://picsum.photos/seed/reel1/400/700',
        caption: '💃 New dance challenge! Tag your friends and try this! #dance #trending #challenge',
        likes: 45200,
        comments: 890,
        shares: 3200,
        isLiked: false,
        isReel: true,
        timeAgo: '1h ago',
      ),
      PostModel(
        id: 'r2',
        userName: 'Chef_Rajan',
        userAvatar: 'https://i.pravatar.cc/150?img=25',
        videoUrl: 'clip_placeholder',
        imageUrl: 'https://picsum.photos/seed/reel2/400/700',
        caption: '🍳 60-second Biryani hack you NEED to try! #cooking #biryani #quickrecipe',
        likes: 78900,
        comments: 1200,
        shares: 5600,
        isLiked: true,
        isReel: true,
        timeAgo: '3h ago',
      ),
      PostModel(
        id: 'r3',
        userName: 'Travel_Vikram',
        userAvatar: 'https://i.pravatar.cc/150?img=33',
        videoUrl: 'clip_placeholder',
        imageUrl: 'https://picsum.photos/seed/reel3/400/700',
        caption: '🏔️ Hidden gem in Coorg — you must visit! #travel #coorg #explore',
        likes: 32100,
        comments: 670,
        shares: 2100,
        isLiked: false,
        isReel: true,
        timeAgo: '5h ago',
      ),
    ];
  }

  static List<Map<String, String>> getStories() {
    return [
      {'name': 'Your Story', 'avatar': 'https://i.pravatar.cc/150?img=1', 'isOwn': 'true'},
      {'name': 'Arjun', 'avatar': 'https://i.pravatar.cc/150?img=11', 'isOwn': 'false'},
      {'name': 'Priya', 'avatar': 'https://i.pravatar.cc/150?img=5', 'isOwn': 'false'},
      {'name': 'Karthik', 'avatar': 'https://i.pravatar.cc/150?img=15', 'isOwn': 'false'},
      {'name': 'Meera', 'avatar': 'https://i.pravatar.cc/150?img=9', 'isOwn': 'false'},
      {'name': 'Divya', 'avatar': 'https://i.pravatar.cc/150?img=20', 'isOwn': 'false'},
    ];
  }

  static List<Map<String, dynamic>> getNotifications() {
    return [
      {
        'avatar': 'https://i.pravatar.cc/150?img=11',
        'text': 'Arjun joined you',
        'sub': 'Grow your Members! 🎉',
        'time': '2m ago',
        'type': 'join',
        'isNew': true,
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'text': '5 new people joined you',
        'sub': 'Priya, Karthik and 3 others',
        'time': '1h ago',
        'type': 'members',
        'isNew': true,
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=20',
        'text': '🔥 Your Clip is trending',
        'sub': '10K views in the last hour!',
        'time': '3h ago',
        'type': 'trending',
        'isNew': true,
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=9',
        'text': 'Meera liked your post',
        'sub': 'Beautiful sunrise this morning! 🌄',
        'time': '5h ago',
        'type': 'like',
        'isNew': false,
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=15',
        'text': '👥 10 new Members joined you',
        'sub': 'Your content is growing!',
        'time': '1d ago',
        'type': 'members',
        'isNew': false,
      },
      {
        'avatar': 'https://i.pravatar.cc/150?img=33',
        'text': 'You joined Ravi',
        'sub': 'Stay updated with their posts',
        'time': '2d ago',
        'type': 'joined',
        'isNew': false,
      },
    ];
  }

  static List<Map<String, dynamic>> getMessages() {
    return [
      {
        'id': 'u1',
        'name': 'Arjun Sharma',
        'avatar': 'https://i.pravatar.cc/150?img=11',
        'lastMsg': 'Hey! Saw your latest post 🔥',
        'time': '2m',
        'unread': 2,
        'online': true,
      },
      {
        'id': 'u2',
        'name': 'Priya Nair',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'lastMsg': 'When is your next Clip coming?',
        'time': '1h',
        'unread': 0,
        'online': true,
      },
      {
        'id': 'u3',
        'name': 'Karthik Dev',
        'avatar': 'https://i.pravatar.cc/150?img=15',
        'lastMsg': 'Loved that shot! 📸',
        'time': '3h',
        'unread': 1,
        'online': false,
      },
      {
        'id': 'u4',
        'name': 'Meera Krishnan',
        'avatar': 'https://i.pravatar.cc/150?img=9',
        'lastMsg': 'Can we collab on a Clip?',
        'time': '1d',
        'unread': 0,
        'online': false,
      },
      {
        'id': 'u5',
        'name': 'Dance_With_Divya',
        'avatar': 'https://i.pravatar.cc/150?img=20',
        'lastMsg': 'Try the new challenge! 💃',
        'time': '2d',
        'unread': 0,
        'online': true,
      },
    ];
  }

  static List<Map<String, dynamic>> searchUsers(String query) {
    final all = [
      {'id': 'u1', 'name': 'Arjun Sharma', 'username': '@arjun_sharma', 'avatar': 'https://i.pravatar.cc/150?img=11', 'members': '1.2K Members', 'isJoined': false},
      {'id': 'u2', 'name': 'Priya Nair', 'username': '@priya_nair', 'avatar': 'https://i.pravatar.cc/150?img=5', 'members': '876 Members', 'isJoined': true},
      {'id': 'u3', 'name': 'Karthik Dev', 'username': '@karthik_dev', 'avatar': 'https://i.pravatar.cc/150?img=15', 'members': '2.1K Members', 'isJoined': false},
      {'id': 'u4', 'name': 'Meera Krishnan', 'username': '@meera_k', 'avatar': 'https://i.pravatar.cc/150?img=9', 'members': '3.4K Members', 'isJoined': true},
      {'id': 'u5', 'name': 'Dance With Divya', 'username': '@dance_divya', 'avatar': 'https://i.pravatar.cc/150?img=20', 'members': '45K Members', 'isJoined': false},
      {'id': 'u6', 'name': 'Chef Rajan', 'username': '@chef_rajan', 'avatar': 'https://i.pravatar.cc/150?img=25', 'members': '78K Members', 'isJoined': false},
      {'id': 'u7', 'name': 'Travel Vikram', 'username': '@travel_vikram', 'avatar': 'https://i.pravatar.cc/150?img=33', 'members': '32K Members', 'isJoined': true},
    ];
    if (query.isEmpty) return all;
    return all.where((u) =>
      (u['name'] as String).toLowerCase().contains(query.toLowerCase()) ||
      (u['username'] as String).toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
