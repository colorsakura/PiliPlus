import 'package:PiliPlus/models/sponsor_block/user_info.dart';

/// Sponsor user info entity
class SponsorUserInfoEntity {
  final String userId;
  final int segmentCount;
  final int viewCount;
  final double minutesSaved;

  SponsorUserInfoEntity({
    required this.userId,
    required this.segmentCount,
    required this.viewCount,
    required this.minutesSaved,
  });

  /// Create from UserInfo model
  factory SponsorUserInfoEntity.fromModel(UserInfo model, String userId) {
    return SponsorUserInfoEntity(
      userId: userId,
      segmentCount: model.segmentCount,
      viewCount: model.viewCount,
      minutesSaved: model.minutesSaved,
    );
  }

  /// Format minutes saved as readable duration
  String get formattedMinutesSaved {
    final hours = (minutesSaved / 60).floor();
    final minutes = (minutesSaved % 60).floor();

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  String toString() =>
      'SponsorUserInfoEntity(userId: $userId, segmentCount: $segmentCount, minutesSaved: $minutesSaved)';
}
