/// 存储键基类
///
/// 定义通用的存储键常量和方法
abstract final class StorageKeys {
  /// 检查键名是否有效
  static bool isValidKey(String key) {
    return key.isNotEmpty && key.trim().isNotEmpty;
  }

  /// 生成带前缀的键名
  static String withPrefix(String prefix, String key) {
    return '${prefix}_$key';
  }
}
