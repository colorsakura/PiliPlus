/// 通用存储仓库接口
///
/// 定义了基本类型的存储操作，支持 String、int、double、bool 和 List<String>
/// 所有实现类（Hive、MMKV 等）都应实现此接口
abstract interface class StorageRepository {
  /// 读取字符串
  String? getString(String key);

  /// 写入字符串
  Future<void> setString(String key, String? value);

  /// 读取整数
  int? getInt(String key);

  /// 写入整数
  Future<void> setInt(String key, int? value);

  /// 读取双精度浮点数
  double? getDouble(String key);

  /// 写入双精度浮点数
  Future<void> setDouble(String key, double? value);

  /// 读取布尔值
  bool? getBool(String key);

  /// 写入布尔值
  Future<void> setBool(String key, bool? value);

  /// 读取字符串列表
  List<String>? getStringList(String key);

  /// 写入字符串列表
  Future<void> setStringList(String key, List<String>? value);

  /// 删除键
  Future<void> remove(String key);

  /// 清空所有数据
  Future<void> clear();

  /// 检查键是否存在
  bool containsKey(String key);

  /// 获取所有键
  List<dynamic> get keys;

  /// 获取所有数据（用于导入导出）
  Map<dynamic, dynamic> toMap();
}
