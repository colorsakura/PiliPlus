// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'danmaku_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for danmaku block rules (Riverpod version)

@ProviderFor(DanmakuFilterController)
final danmakuFilterControllerProvider = DanmakuFilterControllerProvider._();

/// Controller for danmaku block rules (Riverpod version)
final class DanmakuFilterControllerProvider
    extends $NotifierProvider<DanmakuFilterController, DanmakuFilterState> {
  /// Controller for danmaku block rules (Riverpod version)
  DanmakuFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'danmakuFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$danmakuFilterControllerHash();

  @$internal
  @override
  DanmakuFilterController create() => DanmakuFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DanmakuFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DanmakuFilterState>(value),
    );
  }
}

String _$danmakuFilterControllerHash() =>
    r'1f3afabeed54c9a4614295cbabeed7677266f343';

/// Controller for danmaku block rules (Riverpod version)

abstract class _$DanmakuFilterController extends $Notifier<DanmakuFilterState> {
  DanmakuFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DanmakuFilterState, DanmakuFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DanmakuFilterState, DanmakuFilterState>,
              DanmakuFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
