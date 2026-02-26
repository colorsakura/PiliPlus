import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/models/dynamics/up.dart';
import 'package:PiliPlus/features/dynamics/data/datasources/dynamics_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics/domain/entities/dynamics_data.dart';
import 'package:PiliPlus/features/dynamics/domain/entities/follow_up.dart';
import 'package:PiliPlus/features/dynamics/domain/entities/dynamic_item.dart';
import 'package:PiliPlus/features/dynamics/domain/repositories/dynamics_repository.dart';

/// Implementation of the dynamics repository.
class DynamicsRepositoryImpl implements DynamicsRepository {
  const DynamicsRepositoryImpl({
    required DynamicsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final DynamicsRemoteDataSource _remoteDataSource;

  @override
  Future<LoadingState<DynamicsDataEntity>> getDynamics({
    required DynamicsTabType tabType,
    String? offset,
  }) async {
    final result = await _remoteDataSource.getDynamics(
      tabType: tabType,
      offset: offset,
    );

    if (result is Success<DynamicsDataModel>) {
      final response = result.response;
      final items = response.items?.map((item) {
        return DynamicItemEntity(model: item);
      }).toList();

      return Success(
        DynamicsDataEntity(
          items: items,
          hasMore: response.hasMore,
          offset: response.offset,
          total: response.total,
          loadNext: response.loadNext,
        ),
      );
    } else if (result is Error) {
      return Error(result.errMsg);
    } else {
      return LoadingState<DynamicsDataEntity>.loading();
    }
  }

  @override
  Future<LoadingState<FollowUpEntity>> getFollowUp({
    String? offset,
  }) async {
    final result = await _remoteDataSource.getFollowUp();

    if (result is Success<FollowUpModel>) {
      final response = result.response;

      final upList = response.upList.map((item) {
        return UpItemEntity(
          mid: item.mid,
          face: item.face,
          name: item.uname,
          hasUpdate: item.hasUpdate,
        );
      }).toList();

      LiveUsersEntity? liveUsers;
      if (response.liveUsers != null) {
        final liveUserItems = response.liveUsers!.items?.map((item) {
          return LiveUserItemEntity(
            mid: item.mid,
            face: item.face,
            name: item.uname,
            hasUpdate: item.hasUpdate,
            isReserveRecall: item.isReserveRecall,
            jumpUrl: item.jumpUrl,
            roomId: item.roomId,
            title: item.title,
          );
        }).toList();

        liveUsers = LiveUsersEntity(
          count: response.liveUsers!.count,
          group: response.liveUsers!.group,
          items: liveUserItems,
        );
      }

      return Success(
        FollowUpEntity(
          liveUsers: liveUsers,
          upList: upList,
          hasMore: response.hasMore,
          offset: response.offset,
        ),
      );
    } else if (result is Error) {
      return Error(result.errMsg);
    } else {
      return LoadingState<FollowUpEntity>.loading();
    }
  }

  @override
  Future<LoadingState<List<UpItemEntity>>> getAllFollowings({
    required int mid,
    required int page,
  }) async {
    final result = await _remoteDataSource.getAllFollowings(
      mid: mid,
      page: page,
    );

    if (result.isSuccess && result.data != null) {
      final response = result.data!;
      final list = response.list.map((item) {
        return UpItemEntity(
          mid: item.mid,
          face: item.face,
          name: item.uname,
          hasUpdate: null,
        );
      }).toList();

      return Success(list);
    } else if (result is Error) {
      return Error(result.errMsg);
    } else {
      return LoadingState<List<UpItemEntity>>.loading();
    }
  }

  @override
  Future<LoadingState<List<UpItemEntity>>> getDynamicsUpList({
    String? offset,
  }) async {
    final result = await _remoteDataSource.getDynamicsUpList(offset: offset);

    if (result.isSuccess && result.data is DynUpList) {
      final response = result.data as DynUpList;
      final list = response.upList?.map((item) {
        return UpItemEntity(
          mid: item.mid,
          face: item.face,
          name: item.uname,
          hasUpdate: item.hasUpdate,
        );
      }).toList();

      return Success(list ?? []);
    } else if (result is Error) {
      return Error(result.errMsg);
    } else {
      return LoadingState<List<UpItemEntity>>.loading();
    }
  }
}
