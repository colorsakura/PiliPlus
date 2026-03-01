/// 存储配置类
///
/// 定义存储的配置选项
library;

/// 存储类型枚举
enum StorageType { mmkv }

/// 存储配置
///
/// 用于创建不同类型的存储仓库
class StorageConfig {
  /// 存储名称（Box 名称或 MMKV mmapID）
  final String name;

  /// 存储类型
  final StorageType type;

  /// 加密密钥（仅 MMKV 支持，最多16字节）
  final String? cryptKey;

  /// 根目录（仅 MMKV 支持）
  final String? rootDir;

  /// 是否只读（仅 MMKV 支持）
  final bool readOnly;

  /// 预期容量（仅 MMKV 支持）
  final int expectedCapacity;

  const StorageConfig({
    required this.name,
    this.type = StorageType.mmkv,
    this.cryptKey,
    this.rootDir,
    this.readOnly = false,
    this.expectedCapacity = 0,
  });

  /// 创建 MMKV 存储配置
  const StorageConfig.mmkv({
    required this.name,
    this.cryptKey,
    this.rootDir,
    this.readOnly = false,
    this.expectedCapacity = 0,
  }) : type = StorageType.mmkv;

  /// 复制并修改配置
  StorageConfig copyWith({
    String? name,
    StorageType? type,
    String? cryptKey,
    String? rootDir,
    bool? readOnly,
    int? expectedCapacity,
  }) {
    return StorageConfig(
      name: name ?? this.name,
      type: type ?? this.type,
      cryptKey: cryptKey ?? this.cryptKey,
      rootDir: rootDir ?? this.rootDir,
      readOnly: readOnly ?? this.readOnly,
      expectedCapacity: expectedCapacity ?? this.expectedCapacity,
    );
  }

  @override
  String toString() {
    return 'StorageConfig{name: $name, type: $type, readOnly: $readOnly}';
  }
}
