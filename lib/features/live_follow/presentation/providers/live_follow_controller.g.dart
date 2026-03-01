// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_follow_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for live follow list (Riverpod version)

@ProviderFor(LiveFollowController)
final liveFollowControllerProvider = LiveFollowControllerProvider._();

/// Controller for live follow list (Riverpod version)
final class LiveFollowControllerProvider
    extends $NotifierProvider<LiveFollowController, LiveFollowState> {
  /// Controller for live follow list (Riverpod version)
  LiveFollowControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveFollowControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveFollowControllerHash();

  @$internal
  @override
  LiveFollowController create() => LiveFollowController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveFollowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveFollowState>(value),
    );
  }
}

String _$liveFollowControllerHash() =>
    r'0564005030cc2418a9404bee1921664f98abfaeb';

/// Controller for live follow list (Riverpod version)

abstract class _$LiveFollowController extends $Notifier<LiveFollowState> {
  LiveFollowState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveFollowState, LiveFollowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveFollowState, LiveFollowState>,
              LiveFollowState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
