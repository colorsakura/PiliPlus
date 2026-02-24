import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';
import 'package:PiliPlus/features/whisper_block/domain/repositories/whisper_block_repository.dart';

/// Get whisper blocking list use case
class GetWhisperBlockListUseCase {
  final WhisperBlockRepository _repository;

  const GetWhisperBlockListUseCase(this._repository);

  Future<LoadingState<KeywordBlockingListReply>> call() {
    return _repository.getKeywordBlockingList();
  }
}

/// Add whisper blocking keyword use case
class AddWhisperBlockKeywordUseCase {
  final WhisperBlockRepository _repository;

  const AddWhisperBlockKeywordUseCase(this._repository);

  Future<LoadingState<void>> call(String keyword) {
    return _repository.addKeyword(keyword);
  }
}

/// Delete whisper blocking keyword use case
class DeleteWhisperBlockKeywordUseCase {
  final WhisperBlockRepository _repository;

  const DeleteWhisperBlockKeywordUseCase(this._repository);

  Future<LoadingState<void>> call(String keyword) {
    return _repository.deleteKeyword(keyword);
  }
}
