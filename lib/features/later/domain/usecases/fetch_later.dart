import 'package:PiliPlus/features/later/domain/entities/later_result.dart';
import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart';
import 'package:PiliPlus/features/later/domain/repositories/later_repository.dart';

/// 获取稍后再看列表用例
class FetchLaterUseCase {
  final LaterRepository _repository;

  const FetchLaterUseCase(this._repository);

  /// 执行获取稍后再看列表
  Future<LaterResultEntity> call({
    required int page,
    required LaterViewType viewType,
    String keyword = '',
    bool asc = false,
  }) async {
    return await _repository.getLaterList(
      page: page,
      viewType: viewType,
      keyword: keyword,
      asc: asc,
    );
  }
}
