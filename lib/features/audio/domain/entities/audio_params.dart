import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart'
    show DetailItem, PlaylistSource, PlayURLResp, ThumbUpReq_ThumbType;

/// Parameters for fetching audio play URL
class FetchAudioPlayUrlParams {
  final int itemType;
  final int oid;
  final List<int> subId;

  const FetchAudioPlayUrlParams({
    required this.itemType,
    required this.oid,
    required this.subId,
  });
}

/// Parameters for fetching audio playlist
class FetchAudioPlaylistParams {
  final int id;
  final int oid;
  final List<int> subId;
  final int itemType;
  final PlaylistSource from;

  const FetchAudioPlaylistParams({
    required this.id,
    required this.oid,
    required this.subId,
    required this.itemType,
    required this.from,
  });
}

/// Parameters for thumbing up audio
class ThumbUpAudioParams {
  final int oid;
  final List<int> subId;
  final int itemType;
  final bool isThumbUp;

  const ThumbUpAudioParams({
    required this.oid,
    required this.subId,
    required this.itemType,
    required this.isThumbUp,
  });

  int get thumbTypeValue => isThumbUp ? 1 : 2; // 1=LIKE, 2=UN_LIKE
}

/// Parameters for triple like audio
class TripleLikeAudioParams {
  final int oid;
  final List<int> subId;
  final int itemType;

  const TripleLikeAudioParams({
    required this.oid,
    required this.subId,
    required this.itemType,
  });
}

/// Parameters for adding coin to audio
class CoinAudioParams {
  final int oid;
  final List<int> subId;
  final int itemType;
  final int num;
  final bool thumbUp;

  const CoinAudioParams({
    required this.oid,
    required this.subId,
    required this.itemType,
    required this.num,
    required this.thumbUp,
  });
}
