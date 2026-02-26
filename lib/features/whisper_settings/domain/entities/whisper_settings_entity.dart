import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart' show IMSettingType;

/// Parameters for fetching whisper settings
class WhisperSettingsParams {
  /// Settings type
  final IMSettingType imSettingType;

  const WhisperSettingsParams({
    required this.imSettingType,
  });

  @override
  String toString() => 'WhisperSettingsParams(imSettingType: $imSettingType)';
}

/// Entity representing whisper settings result
class WhisperSettingsResult {
  /// Page title
  final String pageTitle;

  /// Settings map
  final Map<int, dynamic> settings;

  const WhisperSettingsResult({
    required this.pageTitle,
    required this.settings,
  });

  @override
  String toString() => 'WhisperSettingsResult(pageTitle: $pageTitle)';
}
