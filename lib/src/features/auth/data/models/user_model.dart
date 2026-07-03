class UserModel {
  int id;
  String username;
  String password;
  String avatarIcon;
  int avatarSetVersion;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    this.avatarIcon = '🔮',
    this.avatarSetVersion = 2,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'avatarIcon': avatarIcon,
        'avatarSetVersion': avatarSetVersion,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as int?) ?? 0,
        username: json['username'] as String,
        password: json['password'] as String,
        avatarIcon: (json['avatarIcon'] as String?) ?? '🔮',
        avatarSetVersion: (json['avatarSetVersion'] as int?) ?? 0,
      );
}
