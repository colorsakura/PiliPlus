class UserStat {
  const UserStat({
    this.following,
    this.follower,
    this.dynamicCount,
  });

  final int? following;
  final int? follower;
  final int? dynamicCount;

  factory UserStat.fromJson(Map<String, dynamic> json) => UserStat(
    following: json['following'],
    follower: json['follower'],
    dynamicCount: json['dynamic_count'],
  );
}
