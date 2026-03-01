import 'package:PiliPlus/features/shell/data/datasources/dynamic_remote_datasource.dart';
import 'package:PiliPlus/features/shell/data/datasources/message_remote_datasource.dart';
import 'package:PiliPlus/features/shell/data/repositories/dynamic_repository_impl.dart';
import 'package:PiliPlus/features/shell/data/repositories/message_repository_impl.dart';
import 'package:PiliPlus/features/shell/domain/repositories/dynamic_repository.dart';
import 'package:PiliPlus/features/shell/domain/repositories/message_repository.dart';
import 'package:PiliPlus/features/shell/domain/usecases/check_unread_dynamics.dart';
import 'package:PiliPlus/features/shell/domain/usecases/check_unread_messages.dart';
import 'package:PiliPlus/features/shell/domain/usecases/periodic_check_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 数据源 Providers
final messageRemoteDataSourceProvider = Provider<MessageRemoteDataSource>((
  ref,
) {
  return MessageRemoteDataSource();
});

final dynamicRemoteDataSourceProvider = Provider<DynamicRemoteDataSource>((
  ref,
) {
  return DynamicRemoteDataSource();
});

/// 仓库 Providers
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(
    remoteDataSource: ref.watch(messageRemoteDataSourceProvider),
  );
});

final dynamicRepositoryProvider = Provider<DynamicRepository>((ref) {
  return DynamicRepositoryImpl(
    remoteDataSource: ref.watch(dynamicRemoteDataSourceProvider),
  );
});

/// Use Case Providers
final checkUnreadMessagesUseCaseProvider = Provider<CheckUnreadMessagesUseCase>(
  (ref) {
    return CheckUnreadMessagesUseCase(
      ref.watch(messageRepositoryProvider),
    );
  },
);

final checkUnreadDynamicsUseCaseProvider = Provider<CheckUnreadDynamicsUseCase>(
  (ref) {
    return CheckUnreadDynamicsUseCase(
      ref.watch(dynamicRepositoryProvider),
    );
  },
);

/// 定时检查调度器 Provider
final periodicCheckSchedulerProvider = Provider<PeriodicCheckScheduler>((ref) {
  final scheduler = PeriodicCheckScheduler(
    checkMessages: ref.read(checkUnreadMessagesUseCaseProvider),
    checkDynamics: ref.read(checkUnreadDynamicsUseCaseProvider),
  );

  ref.onDispose(scheduler.dispose);

  return scheduler;
});
