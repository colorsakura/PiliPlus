import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fan/data/datasources/fan_remote_datasource.dart';
import 'package:PiliPlus/features/fan/data/repositories/fan_repository_impl.dart';
import 'package:PiliPlus/features/fan/domain/repositories/fan_repository.dart';
import 'package:PiliPlus/features/fan/presentation/providers/fan_controller.dart';

// Remote Datasource Provider
final fanRemoteDatasourceProvider = Provider<FanRemoteDatasource>((ref) {
  return FanRemoteDatasource();
});

// Repository Provider
final fanRepositoryProvider = Provider<FanRepository>((ref) {
  final datasource = ref.watch(fanRemoteDatasourceProvider);
  return FanRepositoryImpl(datasource);
});

/// Controller parameters
class FanParams {
  const FanParams({
    required this.mid,
    this.name,
  });

  final int mid;
  final String? name;
}

// Controller Provider - uses Provider.family for different mids
final fanControllerProvider = Provider.family<FanController, FanParams>((
  ref,
  params,
) {
  return FanController(
    mid: params.mid,
    repository: ref.watch(fanRepositoryProvider),
    name: params.name,
  );
});
