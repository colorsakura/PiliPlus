// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_area_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for live area (Riverpod version)

@ProviderFor(LiveAreaListController)
final liveAreaListControllerProvider = LiveAreaListControllerProvider._();

/// Controller for live area (Riverpod version)
final class LiveAreaListControllerProvider
    extends $NotifierProvider<LiveAreaListController, LiveAreaListState> {
  /// Controller for live area (Riverpod version)
  LiveAreaListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveAreaListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveAreaListControllerHash();

  @$internal
  @override
  LiveAreaListController create() => LiveAreaListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveAreaListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveAreaListState>(value),
    );
  }
}

String _$liveAreaListControllerHash() =>
    r'35f2b8aca40e491c18d3ed7df5e1d072984c78e2';

/// Controller for live area (Riverpod version)

abstract class _$LiveAreaListController extends $Notifier<LiveAreaListState> {
  LiveAreaListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveAreaListState, LiveAreaListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveAreaListState, LiveAreaListState>,
              LiveAreaListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
