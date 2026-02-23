/// JSON 序列化编解码器
///
/// 用于在 MMKV 中存储复杂对象时进行 JSON 序列化/反序列化
class JsonCodec<T> {
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  const JsonCodec({
    required this.fromJson,
    required this.toJson,
  });
}

/// 类型化存储接口（支持复杂对象）
///
/// 用于存储需要序列化的复杂对象
/// T: 存储的对象类型
abstract interface class TypedStorageRepository<T> {
  /// 读取对象
  T? get(String key);

  /// 写入对象
  Future<void> set(String key, T? value);

  /// 删除键
  Future<void> remove(String key);

  /// 获取所有数据
  Map<String, T> toMap();

  /// 批量写入
  Future<void> putAll(Map<String, T> map);

  /// 清空
  Future<void> clear();

  /// 获取所有键
  List<dynamic> get keys;

  /// 检查键是否存在
  bool containsKey(String key);
}
