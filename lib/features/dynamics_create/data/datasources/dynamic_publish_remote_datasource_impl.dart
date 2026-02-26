import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/dynamics_create/data/datasources/dynamic_publish_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_create/domain/entities/dynamic_publish_params.dart';

/// Implementation of dynamic publish remote data source using DynamicsHttp
class DynamicPublishRemoteDataSourceImpl implements DynamicPublishRemoteDataSource {
  const DynamicPublishRemoteDataSourceImpl();

  @override
  Future<LoadingState<Map<String, dynamic>?>> createDynamic(CreateDynamicParams params) async {
    final result = await DynamicsHttp.createDynamic(
      mid: params.mid,
      rawText: params.rawText,
      pics: params.pictures as List<Map<String, dynamic>>?,
      publishTime: params.publishTime,
      replyOption: params.replyOption,
      privatePub: params.privatePub,
      title: params.title,
      topic: params.topic,
      extraContent: params.extraContent as List<Map<String, dynamic>>?,
      attachCard: params.attachCard,
    );

    // Convert LoadingState<Map<dynamic, dynamic>?> to LoadingState<Map<String, dynamic>?>
    final converted = switch (result) {
      Success() => Success(
        (result.response as Map<dynamic, dynamic>?)?.cast<String, dynamic>(),
      ),
      Error() => result,
      Loading() => result,
    };
    return converted as LoadingState<Map<String, dynamic>?>;
  }

  @override
  Future<LoadingState<Null>> editDynamic(EditDynamicParams params) {
    return DynamicsHttp.editDyn(
      dynId: params.dynId,
      repostDynId: params.repostDynId,
      rawText: params.rawText,
      pics: params.pictures as List<Map<String, dynamic>>?,
      replyOption: params.replyOption,
      privatePub: params.privatePub,
      title: params.title,
      topic: params.topic,
      extraContent: params.extraContent as List<Map<String, dynamic>>?,
    );
  }
}
