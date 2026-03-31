class UserModel {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String bio;
  final int clips;
  final int members;
  final int joined;
  final bool isJoined;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.clips,
    required this.members,
    required this.joined,
    this.isJoined = false,
  });

  UserModel copyWith({bool? isJoined, int? members}) {
    return UserModel(
      id: id,
      name: name,
      username: username,
      avatar: avatar,
      bio: bio,
      clips: clips,
      members: members ?? this.members,
      joined: joined,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

// Current logged-in user (mock)
const kCurrentUser = UserModel(
  id: 'me',
  name: 'Vettri User',
  username: '@vettri_user',
  avatar: 'https://i.pravatar.cc/150?img=1',
  bio: '🌟 Living life one post at a time | Flutter Dev | Chennai 🏙️',
  clips: 24,
  members: 1240,
  joined: 320,
);
