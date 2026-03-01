// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_area_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for live area detail list (Riverpod version)

@ProviderFor(LiveAreaDetailController)
final liveAreaDetailControllerProvider = LiveAreaDetailControllerFamily._();

/// Controller for live area detail list (Riverpod version)
final class LiveAreaDetailControllerProvider
    extends $NotifierProvider<LiveAreaDetailController, LiveAreaDetailState> {
  /// Controller for live area detail list (Riverpod version)
  LiveAreaDetailControllerProvider._({
    required LiveAreaDetailControllerFamily super.from,
    required (dynamic, dynamic) super.argument,
  }) : super(
         retry: null,
         name: r'liveAreaDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveAreaDetailControllerHash();

  @override
  String toString() {
    return r'liveAreaDetailControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  LiveAreaDetailController create() => LiveAreaDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveAreaDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveAreaDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveAreaDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveAreaDetailControllerHash() =>
    r'05a84e0d324c6da14dec5787216f74cb572a90c4';

/// Controller for live area detail list (Riverpod version)

final class LiveAreaDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveAreaDetailController,
          LiveAreaDetailState,
          LiveAreaDetailState,
          LiveAreaDetailState,
          (dynamic, dynamic)
        > {
  LiveAreaDetailControllerFamily._()
    : super(
        retry: null,
        name: r'liveAreaDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for live area detail list (Riverpod version)

  LiveAreaDetailControllerProvider call(dynamic areaId, dynamic parentAreaId) =>
      LiveAreaDetailControllerProvider._(
        argument: (areaId, parentAreaId),
        from: this,
      );

  @override
  String toString() => r'liveAreaDetailControllerProvider';
}

/// Controller for live area detail list (Riverpod version)

abstract class _$LiveAreaDetailController
    extends $Notifier<LiveAreaDetailState> {
  late final _$args = ref.$arg as (dynamic, dynamic);
  dynamic get areaId => _$args.$1;
  dynamic get parentAreaId => _$args.$2;

  LiveAreaDetailState build(dynamic areaId, dynamic parentAreaId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveAreaDetailState, LiveAreaDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveAreaDetailState, LiveAreaDetailState>,
              LiveAreaDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
