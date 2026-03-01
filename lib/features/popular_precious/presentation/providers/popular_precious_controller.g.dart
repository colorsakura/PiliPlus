// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popular_precious_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for popular precious list (Riverpod version)

@ProviderFor(PopularPreciousController)
final popularPreciousControllerProvider = PopularPreciousControllerProvider._();

/// Controller for popular precious list (Riverpod version)
final class PopularPreciousControllerProvider
    extends $NotifierProvider<PopularPreciousController, PopularPreciousState> {
  /// Controller for popular precious list (Riverpod version)
  PopularPreciousControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularPreciousControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularPreciousControllerHash();

  @$internal
  @override
  PopularPreciousController create() => PopularPreciousController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PopularPreciousState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PopularPreciousState>(value),
    );
  }
}

String _$popularPreciousControllerHash() =>
    r'cfd5ccd5a14a3edeae7a722e23b62ecd32d41e00';

/// Controller for popular precious list (Riverpod version)

abstract class _$PopularPreciousController
    extends $Notifier<PopularPreciousState> {
  PopularPreciousState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PopularPreciousState, PopularPreciousState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PopularPreciousState, PopularPreciousState>,
              PopularPreciousState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
