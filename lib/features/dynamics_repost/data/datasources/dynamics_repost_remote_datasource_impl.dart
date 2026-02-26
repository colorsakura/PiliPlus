import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_repost/data/datasources/dynamics_repost_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_repost/domain/entities/dynamics_repost_params.dart';
import 'package:PiliPlus/http/dynamics.dart' as http;

/// Implementation of dynamic repost remote data source using DynamicsHttp
class DynamicsRepostRemoteDataSourceImpl implements DynamicsRepostRemoteDataSource {
  const DynamicsRepostRemoteDataSourceImpl();

  @override
  Future<LoadingState<Map?>> repostDynamic(DynamicsRepostParams params) {
    return http.DynamicsHttp.createDynamic(
      mid: params.mid,
      dynIdStr: params.dynIdStr,
      rid: params.rid,
      dynType: params.dynType,
      rawText: params.rawText,
      pics: params.pics,
      publishTime: params.publishTime,
      replyOption: params.replyOption,
      privatePub: params.privatePub,
      extraContent: params.extraContent,
      topic: params.topic,
      title: params.title,
      attachCard: params.attachCard,
    );
  }
}
