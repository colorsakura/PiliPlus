import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/reply.dart';
import 'package:PiliPlus/models/emote/package.dart';

/// 表情远程数据源
///
/// 负责从远程API获取表情数据
class EmoteRemoteDataSource {
  /// 获取表情包列表
  Future<LoadingState<List<Package>?>> getEmotePackages({
    required String business,
  }) {
    return ReplyHttp.getEmoteList(business: business);
  }
}
