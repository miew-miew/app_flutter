import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 4)
class UserProfile {
  @HiveField(0)
  final String id; // ex: "me"

  @HiveField(1)
  final String displayName; // ex: "George"

  @HiveField(2)
  final String? avatarEmoji;

  @HiveField(3)
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarEmoji,
    required this.createdAt,
  });
}