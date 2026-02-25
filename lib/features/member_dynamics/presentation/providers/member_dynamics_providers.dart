import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_dynamics/data/datasources/member_dynamics_remote_datasource.dart';
import 'package:PiliPlus/features/member_dynamics/data/repositories/member_dynamics_repository_impl.dart';
import 'package:PiliPlus/features/member_dynamics/domain/repositories/member_dynamics_repository.dart';
import 'package:PiliPlus/features/member_dynamics/presentation/providers/member_dynamics_controller.dart';

// Remote Datasource Provider
final memberDynamicsRemoteDatasourceProvider =
    Provider<MemberDynamicsRemoteDatasource>((ref) {
      return const MemberDynamicsRemoteDatasource();
    });

// Repository Provider
final memberDynamicsRepositoryProvider = Provider<MemberDynamicsRepository>((
  ref,
) {
  final datasource = ref.watch(memberDynamicsRemoteDatasourceProvider);
  return MemberDynamicsRepositoryImpl(datasource);
});

/// Controller parameters
class MemberDynamicsParams {
  const MemberDynamicsParams({
    required this.mid,
  });

  final int mid;
}

// Controller Provider - uses Provider.family for different mids
final memberDynamicsControllerProvider =
    Provider.family<MemberDynamicsController, MemberDynamicsParams>((
      ref,
      params,
    ) {
      return MemberDynamicsController(
        mid: params.mid,
        repository: ref.watch(memberDynamicsRepositoryProvider),
      );
    });
