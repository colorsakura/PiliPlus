import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/reply/domain/usecases/get_reply_list.dart';
import 'package:PiliPlus/features/reply/data/repositories/reply_repository_impl.dart';
import 'package:PiliPlus/features/reply/data/datasources/reply_remote_datasource.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'reply_list_controller.g.dart';

/// Provider for ReplyRemoteDataSource
final replyRemoteDataSourceProvider = Provider<ReplyRemoteDataSource>((ref) {
  return ReplyRemoteDataSource();
});

/// Provider for ReplyRepository
final replyRepositoryProvider = Provider<ReplyRepositoryImpl>((ref) {
  final datasource = ref.watch(replyRemoteDataSourceProvider);
  return ReplyRepositoryImpl(remoteDataSource: datasource);
});

/// Provider for GetReplyList use case
final getReplyListProvider = Provider<GetReplyList>((ref) {
  final repository = ref.watch(replyRepositoryProvider);
  return GetReplyList(repository);
});

/// Reply list state
class ReplyListState {
  final ReplyData? replyData;
  final bool isLoading;
  final String? errorMessage;

  const ReplyListState({
    this.replyData,
    this.isLoading = false,
    this.errorMessage,
  });

  ReplyListState copyWith({
    ReplyData? replyData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReplyListState(
      replyData: replyData ?? this.replyData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Controller for managing reply lists
@riverpod
class ReplyListController extends _$ReplyListController {
  @override
  ReplyListState build() {
    return const ReplyListState();
  }

  /// Fetch reply list
  Future<void> fetchReplyList({
    required bool isLogin,
    required int oid,
    required String nextOffset,
    required int type,
    required int page,
    int sort = 1,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final getReply = ref.read(getReplyListProvider);
      final result = await getReply(
        isLogin: isLogin,
        oid: oid,
        nextOffset: nextOffset,
        type: type,
        page: page,
        sort: sort,
      );

      switch (result) {
        case Success(:final response):
          state = state.copyWith(
            replyData: response,
            isLoading: false,
          );
        case Error(:final errMsg):
          state = state.copyWith(
            isLoading: false,
            errorMessage: errMsg,
          );
        case Loading():
          break;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear reply data
  void clearReplyData() {
    state = const ReplyListState();
  }
}
