import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/emote/package.dart';
import 'package:PiliPlus/features/reply/domain/repositories/reply_repository.dart';

/// Get emote list use case
class GetEmoteList {
  final ReplyRepository repository;

  const GetEmoteList(this.repository);

  Future<LoadingState<List<Package>?>> call({
    String? business,
  }) {
    return repository.getEmoteList(business: business);
  }
}
