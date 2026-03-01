// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popular_series_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Popular series controller (Riverpod version)

@ProviderFor(PopularSeriesListController)
final popularSeriesListControllerProvider =
    PopularSeriesListControllerProvider._();

/// Popular series controller (Riverpod version)
final class PopularSeriesListControllerProvider
    extends
        $NotifierProvider<PopularSeriesListController, PopularSeriesListState> {
  /// Popular series controller (Riverpod version)
  PopularSeriesListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularSeriesListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularSeriesListControllerHash();

  @$internal
  @override
  PopularSeriesListController create() => PopularSeriesListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PopularSeriesListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PopularSeriesListState>(value),
    );
  }
}

String _$popularSeriesListControllerHash() =>
    r'a9b6a9bce0f6545d0f487850035e02066b6f64b0';

/// Popular series controller (Riverpod version)

abstract class _$PopularSeriesListController
    extends $Notifier<PopularSeriesListState> {
  PopularSeriesListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PopularSeriesListState, PopularSeriesListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PopularSeriesListState, PopularSeriesListState>,
              PopularSeriesListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
