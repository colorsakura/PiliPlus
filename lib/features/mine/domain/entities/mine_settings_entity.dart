import 'package:PiliPlus/app/theme/entities/theme_type.dart';

/// 我的页面设置实体
///
/// 包含我的页面的各种设置
class MineSettingsEntity {
  /// 主题类型
  final ThemeType themeType;

  /// 是否匿名模式
  final bool isAnonymous;

  const MineSettingsEntity({
    required this.themeType,
    this.isAnonymous = false,
  });

  MineSettingsEntity copyWith({
    ThemeType? themeType,
    bool? isAnonymous,
  }) {
    return MineSettingsEntity(
      themeType: themeType ?? this.themeType,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// 获取下一个主题类型
  ThemeType get nextThemeType {
    final currentIndex = ThemeType.values.indexOf(themeType);
    final nextIndex = (currentIndex + 1) % ThemeType.values.length;
    return ThemeType.values[nextIndex];
  }

  /// 创建默认设置
  factory MineSettingsEntity.defaultSettings() {
    return MineSettingsEntity(
      themeType: ThemeType.system,
    );
  }
}
