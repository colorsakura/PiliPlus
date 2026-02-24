import 'package:PiliPlus/features/emote/domain/repositories/emote_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/emote/package.dart';

/// 获取表情包用例
///
/// 负责获取表情包列表的业务逻辑
class GetEmotePackagesUseCase {
  final EmoteRepository _repository;

  const GetEmotePackagesUseCase(this._repository);

  /// 获取表情包列表
  Future<LoadingState<List<Package>?>> call({required String business}) {
    return _repository.getEmotePackages(business: business);
  }
}
