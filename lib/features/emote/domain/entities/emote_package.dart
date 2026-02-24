import 'package:PiliPlus/models/emote/package.dart';

/// 表情包实体
///
/// 封装表情包数据模型
class EmotePackageEntity {
  /// 表情包列表
  final List<Package>? packages;

  const EmotePackageEntity({
    this.packages,
  });

  /// 从模型创建实体
  factory EmotePackageEntity.fromModel(List<Package>? packages) {
    return EmotePackageEntity(
      packages: packages,
    );
  }
}
