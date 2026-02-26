/// Music remote data source interface
abstract class MusicRemoteDataSource {
  /// Get music detail raw data
  Future<Map<String, dynamic>> getBgmDetail(String musicId);

  /// Update favorite status
  Future<void> updateWishStatus({
    required String musicId,
    required bool hasLike,
  });

  /// Get music recommendations raw data
  Future<List<dynamic>?> getBgmRecommend(String musicId);
}
