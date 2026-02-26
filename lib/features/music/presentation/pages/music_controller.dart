import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/music/bgm_detail.dart';
import 'package:PiliPlus/core/controllers/common_dyn_controller.dart';
import 'package:PiliPlus/features/music/data/datasources/music_api_datasource.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:get/get.dart';

class MusicDetailController extends CommonDynController {
  final _dataSource = MusicRemoteDataSource();

  @override
  late final int oid;
  @override
  late final int replyType;

  @override
  dynamic get sourceId => oid.toString();

  final infoState = LoadingState<MusicDetail>.loading().obs;

  late final String musicId;

  bool get showDynActionBar => Pref.showDynActionBar;

  String get shareUrl =>
      'https://music.bilibili.com/h5/music-detail?music_id=$musicId';

  @override
  void onInit() {
    super.onInit();
    musicId = Get.parameters['musicId']!;
    getMusicDetail();
  }

  Future<void> getMusicDetail() async {
    try {
      final result = await _dataSource.bgmDetail(musicId);
      final response = MusicDetail.fromJson(result);
      final comment = response.musicComment!;
      oid = comment.oid!;
      replyType = comment.pageType ?? 47;
      count.value = comment.nums ?? -1;
      queryData();
      infoState.value = Success(response);
    } catch (e) {
      infoState.value = Error(e.toString());
    }
  }
}
