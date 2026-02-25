import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live_dm_block/data/datasources/live_dm_block_remote_datasource.dart';
import 'package:PiliPlus/features/live_dm_block/data/repositories/live_dm_block_repository_impl.dart';
import 'package:PiliPlus/features/live_dm_block/domain/repositories/live_dm_block_repository.dart';
import 'package:PiliPlus/features/live_dm_block/presentation/providers/live_dm_block_controller.dart';

// Remote Datasource Provider
final liveDmBlockRemoteDatasourceProvider =
    Provider<LiveDmBlockRemoteDatasource>((ref) {
      return const LiveDmBlockRemoteDatasource();
    });

// Repository Provider
final liveDmBlockRepositoryProvider = Provider<LiveDmBlockRepository>((ref) {
  final datasource = ref.watch(liveDmBlockRemoteDatasourceProvider);
  return LiveDmBlockRepositoryImpl(datasource);
});

// Controller Provider - uses Provider.family for different roomIds
final liveDmBlockControllerProvider =
    Provider.family<LiveDmBlockController, String>((ref, roomId) {
      return LiveDmBlockController(
        roomId: roomId,
        repository: ref.watch(liveDmBlockRepositoryProvider),
      );
    });
