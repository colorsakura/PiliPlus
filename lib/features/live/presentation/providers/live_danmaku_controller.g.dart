// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_danmaku_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing live danmaku (chat messages)

@ProviderFor(LiveDanmakuController)
final liveDanmakuControllerProvider = LiveDanmakuControllerProvider._();

/// Controller for managing live danmaku (chat messages)
final class LiveDanmakuControllerProvider
    extends $NotifierProvider<LiveDanmakuController, LiveDanmakuState> {
  /// Controller for managing live danmaku (chat messages)
  LiveDanmakuControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveDanmakuControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveDanmakuControllerHash();

  @$internal
  @override
  LiveDanmakuController create() => LiveDanmakuController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveDanmakuState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveDanmakuState>(value),
    );
  }
}

String _$liveDanmakuControllerHash() =>
    r'0cb09d6e879f627cb5748682e883a2913577bbfd';

/// Controller for managing live danmaku (chat messages)

abstract class _$LiveDanmakuController extends $Notifier<LiveDanmakuState> {
  LiveDanmakuState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveDanmakuState, LiveDanmakuState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveDanmakuState, LiveDanmakuState>,
              LiveDanmakuState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
