/// 我的页面设置实体
///
/// 包含我的页面的各种设置
class MineSettingsEntity {
  /// 主题类型 (use ThemeMode instead)
  final String themeType; // Note: This was ThemeType, now simplified to String

  /// 是否匿名模式
  final bool isAnonymous;

  const MineSettingsEntity({
    required this.themeType,
    this.isAnonymous = false,
  });

  MineSettingsEntity copyWith({
    String? themeType,
    bool? isAnonymous,
  }) {
    return MineSettingsEntity(
      themeType: themeType ?? this.themeType,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// 创建默认设置
  factory MineSettingsEntity.defaultSettings() {
    return MineSettingsEntity(
      themeType: 'system', // Default to system theme
    );
  }
}
