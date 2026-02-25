import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/msg_at_me/data/datasources/msg_at_me_remote_datasource.dart';
import 'package:PiliPlus/features/msg_at_me/data/repositories/msg_at_me_repository_impl.dart';
import 'package:PiliPlus/features/msg_at_me/domain/repositories/msg_at_me_repository.dart';
import 'package:PiliPlus/features/msg_at_me/domain/usecases/get_msg_at_me_items_usecase.dart';
import 'package:PiliPlus/features/msg_at_me/domain/usecases/remove_msg_item_usecase.dart';
import 'package:PiliPlus/features/msg_at_me/presentation/providers/msg_at_me_controller.dart';

// Remote Datasource Provider
final msgAtMeRemoteDatasourceProvider = Provider<MsgAtMeRemoteDatasource>((
  ref,
) {
  return const MsgAtMeRemoteDatasource();
});

// Repository Provider
final msgAtMeRepositoryProvider = Provider<MsgAtMeRepository>((ref) {
  final datasource = ref.watch(msgAtMeRemoteDatasourceProvider);
  return MsgAtMeRepositoryImpl(datasource);
});

// Use Cases Providers
final getMsgAtMeItemsUseCaseProvider = Provider<GetMsgAtMeItemsUseCase>((ref) {
  final repository = ref.watch(msgAtMeRepositoryProvider);
  return GetMsgAtMeItemsUseCase(repository);
});

final removeMsgItemUseCaseProvider = Provider<RemoveMsgItemUseCase>((ref) {
  final repository = ref.watch(msgAtMeRepositoryProvider);
  return RemoveMsgItemUseCase(repository);
});

// Controller Provider
final msgAtMeControllerProvider = Provider<MsgAtMeController>((ref) {
  final getItemsUseCase = ref.watch(getMsgAtMeItemsUseCaseProvider);
  final removeItemUseCase = ref.watch(removeMsgItemUseCaseProvider);
  return MsgAtMeController(
    getItemsUseCase: getItemsUseCase,
    removeItemUseCase: removeItemUseCase,
  );
});
