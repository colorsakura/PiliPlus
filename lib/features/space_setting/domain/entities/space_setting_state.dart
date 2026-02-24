import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_setting/privacy.dart';

/// Space setting state
class SpaceSettingState {
  final LoadingState<Privacy?> privacy;

  const SpaceSettingState({
    required this.privacy,
  });

  SpaceSettingState copyWith({
    LoadingState<Privacy?>? privacy,
  }) {
    return SpaceSettingState(
      privacy: privacy ?? this.privacy,
    );
  }
}
