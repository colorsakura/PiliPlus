import 'package:PiliPlus/features/dynamics_mention/data/datasources/dyn_mention_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_mention/domain/repositories/dyn_mention_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';

/// Implementation of dynamic mention repository
///
/// Provides access to dynamic mention data through remote data source.
class DynMentionRepositoryImpl implements DynMentionRepository {
  final DynMentionRemoteDatasource remoteDatasource;

  DynMentionRepositoryImpl({required this.remoteDatasource});

  @override
  Future<LoadingState<List<MentionGroup>?>> searchMentions({String? keyword}) {
    return remoteDatasource.searchMentions(keyword: keyword);
  }
}
