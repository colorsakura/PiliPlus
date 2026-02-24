import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';

/// Whisper block entity
class WhisperBlockEntity {
  final List<KeywordBlockingItem> items;
  final int count;
  final int? listLimit;
  final int? charLimit;

  const WhisperBlockEntity({
    required this.items,
    required this.count,
    this.listLimit,
    this.charLimit,
  });

  /// Create from gRPC response
  factory WhisperBlockEntity.fromResponse(KeywordBlockingListReply response) {
    return WhisperBlockEntity(
      items: response.items,
      count: response.items.length,
      listLimit: response.listLimit,
      charLimit: response.charLimit,
    );
  }
}
