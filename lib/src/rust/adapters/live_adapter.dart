import 'package:PiliPlus/models/live/live_room_info_h5/anchor_info.dart';
import 'package:PiliPlus/models/live/live_room_info_h5/base_info.dart';
import 'package:PiliPlus/models/live/live_room_info_h5/room_info.dart';
import 'package:PiliPlus/models/live/live_room_info_h5/data.dart';
import 'package:PiliPlus/models/live/live_room_play_info/codec.dart';
import 'package:PiliPlus/models/live/live_room_play_info/data.dart';
import 'package:PiliPlus/models/live/live_room_play_info/format.dart';
import 'package:PiliPlus/models/live/live_room_play_info/playurl.dart';
import 'package:PiliPlus/models/live/live_room_play_info/playurl_info.dart';
import 'package:PiliPlus/models/live/live_room_play_info/stream.dart';
import 'package:PiliPlus/src/rust/models/live.dart' as rust;

/// Adapter for converting Rust Live models to Flutter Live models.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/live/)
///
/// Supported conversions:
/// - `LiveRoomInfo` (Rust) → `RoomInfoH5Data` (Flutter)
/// - `LivePlayUrl` (Rust) → `RoomPlayInfoData` (Flutter)
///
/// Note: The Rust Live models are simplified subsets of the full Flutter
/// models. Fields not present in Rust are left null or set to defaults.
class LiveAdapter {
  /// Convert Rust LiveRoomInfo to Flutter RoomInfoH5Data.
  ///
  /// The Rust model contains basic room information. Flutter models require
  /// nested RoomInfo and AnchorInfo objects, which we construct here.
  static RoomInfoH5Data fromRustRoomInfo(rust.LiveRoomInfo rustRoomInfo) {
    return RoomInfoH5Data(
      roomInfo: RoomInfo(
        roomId: rustRoomInfo.roomId.toInt(),
        uid: rustRoomInfo.uid.toInt(),
        title: rustRoomInfo.title,
        cover: rustRoomInfo.cover.url,
        liveStatus: _mapLiveStatus(rustRoomInfo.status),
        liveStartTime: null, // Not in Rust model
        online: rustRoomInfo.onlineCount.toInt(),
        appBackground: null, // Not in Rust model
        subSessionKey: null, // Not in Rust model
      ),
      anchorInfo: AnchorInfo(
        baseInfo: BaseInfo(
          uname: null, // Not in Rust model
          face: null, // Not in Rust model
        ),
      ),
      watchedShow: null, // Not in Rust model
    );
  }

  /// Convert Rust LivePlayUrl to Flutter RoomPlayInfoData.
  ///
  /// The Rust model contains quality and URLs. We construct the full Flutter
  /// playback info structure with stream, format, and codec information.
  static RoomPlayInfoData fromRustPlayUrl(
    int roomId,
    rust.LivePlayUrl rustPlayUrl,
  ) {
    // Map Rust quality enum to Flutter quality code
    final qualityCode = _mapQualityToCode(rustPlayUrl.quality);

    return RoomPlayInfoData(
      roomId: roomId,
      shortId: roomId, // Use same ID
      uid: null, // Not in Rust model
      isPortrait: null, // Not in Rust model
      liveStatus: null, // Not in Rust model
      liveTime: null, // Not in Rust model
      playurlInfo: PlayurlInfo(
        playurl: Playurl(
          cid: null, // Not in Rust model
          stream: [
            Stream(
              protocolName: 'http_hls',
              format: [
                Format(
                  formatName: 'fmp4',
                  codec: [
                    CodecItem(
                      codecName: 'avc',
                      currentQn: qualityCode,
                      acceptQn: [qualityCode],
                      baseUrl: rustPlayUrl.urls.firstOrNull ?? '',
                      urlInfo: null, // Not in Rust model
                      hdrQn: null, // Not in Rust model
                      dolbyType: null, // Not in Rust model
                      attrName: null, // Not in Rust model
                      hdrType: null, // Not in Rust model
                    ),
                  ],
                  masterUrl: null, // Not in Rust model
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Map Rust LiveStatus to Flutter liveStatus int.
  ///
  /// Flutter uses: 0=preview, 1=live, 2=round
  /// Rust uses: LiveStatus enum (preview, live, round)
  static int _mapLiveStatus(rust.LiveStatus status) {
    return switch (status) {
      rust.LiveStatus.preview => 0,
      rust.LiveStatus.live => 1,
      rust.LiveStatus.round => 2,
    };
  }

  /// Map Rust LiveQuality to Flutter quality code.
  ///
  /// Flutter quality codes:
  /// - 10000: origin (4K)
  /// - 400: blue (1080P)
  /// - 250: high (720P)
  /// - 150: medium (480P)
  /// - 80: low (360P)
  static int _mapQualityToCode(rust.LiveQuality quality) {
    return switch (quality) {
      rust.LiveQuality.ultra => 10000,
      rust.LiveQuality.high => 400,
      rust.LiveQuality.medium => 250,
      rust.LiveQuality.low => 80,
    };
  }
}
