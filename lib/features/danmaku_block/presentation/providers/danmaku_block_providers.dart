import 'package:PiliPlus/features/danmaku_block/data/datasources/danmaku_block_remote_datasource.dart';
import 'package:PiliPlus/features/danmaku_block/data/repositories/danmaku_block_repository_impl.dart';
import 'package:PiliPlus/features/danmaku_block/domain/repositories/danmaku_block_repository.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/get_danmaku_filter_rules_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/delete_danmaku_rule_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/domain/usecases/add_danmaku_rule_usecase.dart';
import 'package:PiliPlus/features/danmaku_block/presentation/providers/danmaku_block_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote datasource provider
final danmakuBlockRemoteDatasourceProvider =
    Provider<DanmakuBlockRemoteDatasource>((ref) {
      return DanmakuBlockRemoteDatasource();
    });

/// Repository provider
final danmakuBlockRepositoryProvider = Provider<DanmakuBlockRepository>((ref) {
  final datasource = ref.watch(danmakuBlockRemoteDatasourceProvider);
  return DanmakuBlockRepositoryImpl(datasource);
});

/// Get danmaku filter rules use case provider
final getDanmakuFilterRulesUseCaseProvider =
    Provider<GetDanmakuFilterRulesUseCase>((ref) {
      final repository = ref.watch(danmakuBlockRepositoryProvider);
      return GetDanmakuFilterRulesUseCase(repository);
    });

/// Delete danmaku rule use case provider
final deleteDanmakuRuleUseCaseProvider = Provider<DeleteDanmakuRuleUseCase>((
  ref,
) {
  final repository = ref.watch(danmakuBlockRepositoryProvider);
  return DeleteDanmakuRuleUseCase(repository);
});

/// Add danmaku rule use case provider
final addDanmakuRuleUseCaseProvider = Provider<AddDanmakuRuleUseCase>((ref) {
  final repository = ref.watch(danmakuBlockRepositoryProvider);
  return AddDanmakuRuleUseCase(repository);
});

/// Danmaku block controller provider
final danmakuBlockControllerProvider = Provider<DanmakuBlockController>((ref) {
  return DanmakuBlockController(
    getDanmakuFilterRulesUseCase: ref.watch(
      getDanmakuFilterRulesUseCaseProvider,
    ),
    deleteDanmakuRuleUseCase: ref.watch(deleteDanmakuRuleUseCaseProvider),
    addDanmakuRuleUseCase: ref.watch(addDanmakuRuleUseCaseProvider),
  );
});
