import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/features/member_pgc/data/datasources/member_pgc_remote_datasource.dart';
import 'package:PiliPlus/features/member_pgc/data/repositories/member_pgc_repository_impl.dart';
import 'package:PiliPlus/features/member_pgc/domain/repositories/member_pgc_repository.dart';
import 'package:PiliPlus/features/member_pgc/presentation/providers/member_pgc_controller.dart';

// Remote Datasource Provider
final memberPgcRemoteDatasourceProvider = Provider<MemberPgcRemoteDatasource>((
  ref,
) {
  return const MemberPgcRemoteDatasource();
});

// Repository Provider
final memberPgcRepositoryProvider = Provider<MemberPgcRepository>((ref) {
  final datasource = ref.watch(memberPgcRemoteDatasourceProvider);
  return MemberPgcRepositoryImpl(datasource);
});

/// Controller parameters - includes initial data from parent controller
class MemberPgcParams {
  const MemberPgcParams({
    required this.mid,
    this.initialData,
  });

  final int mid;
  final SpaceData? initialData;
}

// Controller Provider - uses Provider.family for different params
final memberPgcControllerProvider =
    Provider.family<MemberPgcController, MemberPgcParams>((ref, params) {
      return MemberPgcController(
        mid: params.mid,
        repository: ref.watch(memberPgcRepositoryProvider),
        initialData: params.initialData,
      );
    });
