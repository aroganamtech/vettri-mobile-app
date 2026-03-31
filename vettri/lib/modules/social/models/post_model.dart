class PostModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String? imageUrl;
  final String? videoUrl;
  final String caption;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isReel;
  final String timeAgo;

  PostModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    this.imageUrl,
    this.videoUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    this.isReel = false,
    required this.timeAgo,
  });

  PostModel copyWith({bool? isLiked, int? likes}) {
    return PostModel(
      id: id,
      userName: userName,
      userAvatar: userAvatar,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      caption: caption,
      likes: likes ?? this.likes,
      comments: comments,
      shares: shares,
      isLiked: isLiked ?? this.isLiked,
      isReel: isReel,
      timeAgo: timeAgo,
    );
  }
}
