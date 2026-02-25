import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper_block/domain/entities/whisper_block_entity.dart';
import 'package:PiliPlus/features/whisper_block/domain/entities/whisper_block_state.dart';
import 'package:PiliPlus/features/whisper_block/domain/usecases/whisper_block_usecases.dart';
import 'package:PiliPlus/features/whisper_block/data/datasources/whisper_block_remote_datasource.dart';
import 'package:PiliPlus/features/whisper_block/data/repositories/whisper_block_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whisper block controller
class WhisperBlockController extends Notifier<WhisperBlockState> {
  late final GetWhisperBlockListUseCase _getListUseCase;
  late final AddWhisperBlockKeywordUseCase _addKeywordUseCase;
  late final DeleteWhisperBlockKeywordUseCase _deleteKeywordUseCase;

  @override
  WhisperBlockState build() {
    final datasource = WhisperBlockRemoteDatasource();
    final repository = WhisperBlockRepositoryImpl(datasource);
    _getListUseCase = GetWhisperBlockListUseCase(repository);
    _addKeywordUseCase = AddWhisperBlockKeywordUseCase(repository);
    _deleteKeywordUseCase = DeleteWhisperBlockKeywordUseCase(repository);

    // Auto-load on first access
    fetchBlockList();

    return WhisperBlockState(
      data: LoadingState.loading(),
    );
  }

  /// Fetch whisper block list
  Future<void> fetchBlockList() async {
    final result = await _getListUseCase();

    state = switch (result) {
      Loading() => WhisperBlockState(
        data: LoadingState.loading(),
      ),
      Success(:final response) => () {
        final entity = WhisperBlockEntity.fromResponse(response);
        return WhisperBlockState(
          data: Success(entity),
        );
      }(),
      Error() => WhisperBlockState(
        data: result,
      ),
    };
  }

  /// Add keyword to block list
  Future<bool> addKeyword(String keyword) async {
    final result = await _addKeywordUseCase(keyword);

    return switch (result) {
      Error(:final errMsg) => () {
        state = state.copyWith(
          data: Error(errMsg),
        );
        return false;
      }(),
      Loading() => false,
      Success() => () {
        // Update local state
        final currentData = state.data;
        if (currentData is Success<WhisperBlockEntity>) {
          final entity = currentData.response;
          if (entity != null) {
            final updatedList = [
              ...entity.items,
              KeywordBlockingItem(keyword: keyword),
            ];
            final updatedEntity = WhisperBlockEntity(
              items: updatedList,
              count: updatedList.length,
              listLimit: entity.listLimit,
              charLimit: entity.charLimit,
            );
            state = state.copyWith(
              data: Success(updatedEntity),
            );
          }
        }
        return true;
      }(),
    };
  }

  /// Remove keyword from block list
  Future<bool> removeKeyword(KeywordBlockingItem item) async {
    final result = await _deleteKeywordUseCase(item.keyword);

    return switch (result) {
      Error(:final errMsg) => () {
        state = state.copyWith(
          data: Error(errMsg),
        );
        return false;
      }(),
      Loading() => false,
      Success() => () {
        // Update local state
        final currentData = state.data;
        if (currentData is Success<WhisperBlockEntity>) {
          final entity = currentData.response;
          if (entity != null) {
            final updatedList = entity.items.where((e) => e != item).toList();
            final updatedEntity = WhisperBlockEntity(
              items: updatedList,
              count: updatedList.length,
              listLimit: entity.listLimit,
              charLimit: entity.charLimit,
            );
            state = state.copyWith(
              data: Success(updatedEntity),
            );
          }
        }
        return true;
      }(),
    };
  }

  /// Reload data
  Future<void> onReload() => fetchBlockList();
}

/// Whisper block controller provider
final whisperBlockControllerProvider =
    NotifierProvider<WhisperBlockController, WhisperBlockState>(
      WhisperBlockController.new,
    );
