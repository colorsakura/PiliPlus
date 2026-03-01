// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'see_you_later_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing "See You Later" (watch later) list

@ProviderFor(SeeYouLaterController)
final seeYouLaterControllerProvider = SeeYouLaterControllerProvider._();

/// Controller for managing "See You Later" (watch later) list
final class SeeYouLaterControllerProvider
    extends $NotifierProvider<SeeYouLaterController, SeeYouLaterState> {
  /// Controller for managing "See You Later" (watch later) list
  SeeYouLaterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seeYouLaterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seeYouLaterControllerHash();

  @$internal
  @override
  SeeYouLaterController create() => SeeYouLaterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeeYouLaterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeeYouLaterState>(value),
    );
  }
}

String _$seeYouLaterControllerHash() =>
    r'bda2833371627a309cf5a50eda8daae7ce783724';

/// Controller for managing "See You Later" (watch later) list

abstract class _$SeeYouLaterController extends $Notifier<SeeYouLaterState> {
  SeeYouLaterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SeeYouLaterState, SeeYouLaterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SeeYouLaterState, SeeYouLaterState>,
              SeeYouLaterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
