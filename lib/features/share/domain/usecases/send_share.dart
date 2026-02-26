import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/share/domain/entities/share_user.dart';
import 'package:PiliPlus/features/share/domain/repositories/share_repository.dart';

/// Send share use case
class SendShare {
  final ShareRepository repository;

  const SendShare(this.repository);

  Future<LoadingState<Map<int, bool>>> call({
    required List<ShareUserEntity> users,
    required Map content,
    String? message,
  }) {
    return repository.sendShare(
      users: users,
      content: content,
      message: message,
    );
  }
}
