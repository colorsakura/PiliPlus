/// Danmaku remote data source interface
abstract class DanmakuRemoteDataSource {
  /// Send danmaku
  Future<Map<String, dynamic>> shootDanmaku({
    int type = 1,
    required int oid,
    required String msg,
    int mode = 1,
    required String bvid,
    int? progress,
    int? color,
    int? fontSize,
    int? pool,
    bool colorful = false,
    int? checkboxType,
  });
}
