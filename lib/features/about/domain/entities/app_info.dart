/// 应用信息实体
///
/// 封装应用的基本信息
class AppInfoEntity {
  /// 应用名称
  final String appName;

  /// 版本名称
  final String versionName;

  /// 版本号
  final int versionCode;

  /// 完整版本字符串
  final String fullVersion;

  /// 构建时间（Unix时间戳）
  final int buildTime;

  /// 提交哈希
  final String commitHash;

  /// 源代码URL
  final String sourceCodeUrl;

  const AppInfoEntity({
    required this.appName,
    required this.versionName,
    required this.versionCode,
    required this.fullVersion,
    required this.buildTime,
    required this.commitHash,
    required this.sourceCodeUrl,
  });

  /// 获取提交URL
  String get commitUrl => '$sourceCodeUrl/commit/$commitHash';

  /// 获取问题反馈URL
  String get issuesUrl => '$sourceCodeUrl/issues';
}
