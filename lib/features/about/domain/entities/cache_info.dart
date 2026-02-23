/// 缓存信息实体
///
/// 封装应用缓存相关数据
class CacheInfoEntity {
  /// 缓存大小（字节）
  final int sizeInBytes;

  /// 格式化后的缓存大小字符串
  final String formattedSize;

  const CacheInfoEntity({
    required this.sizeInBytes,
    required this.formattedSize,
  });

  /// 空缓存
  factory CacheInfoEntity.empty() {
    return const CacheInfoEntity(
      sizeInBytes: 0,
      formattedSize: '0 B',
    );
  }

  /// 是否有缓存
  bool get hasCache => sizeInBytes > 0;
}
