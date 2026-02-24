import 'package:PiliPlus/models/space_setting/privacy.dart';

/// Space setting entity
class SpaceSettingEntity {
  final Privacy? privacy;

  const SpaceSettingEntity({
    this.privacy,
  });

  /// Convert from model
  factory SpaceSettingEntity.fromModel(Privacy? privacy) {
    return SpaceSettingEntity(
      privacy: privacy,
    );
  }
}
