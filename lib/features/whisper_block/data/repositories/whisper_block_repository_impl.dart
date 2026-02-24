import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper_block/domain/repositories/whisper_block_repository.dart';
import 'package:PiliPlus/features/whisper_block/data/datasources/whisper_block_remote_datasource.dart';

/// Whisper block repository implementation
class WhisperBlockRepositoryImpl implements WhisperBlockRepository {
  final WhisperBlockRemoteDatasource _remoteDatasource;

  WhisperBlockRepositoryImpl(this._remoteDatasource);

  @override
  Future<LoadingState<void>> addKeyword(String keyword) {
    return _remoteDatasource.addKeyword(keyword);
  }

  @override
  Future<LoadingState<void>> deleteKeyword(String keyword) {
    return _remoteDatasource.deleteKeyword(keyword);
  }

  @override
  Future<LoadingState<KeywordBlockingListReply>> getKeywordBlockingList() {
    return _remoteDatasource.getKeywordBlockingList();
  }
}
