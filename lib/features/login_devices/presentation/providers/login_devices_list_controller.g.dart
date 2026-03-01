// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_devices_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for login devices (Riverpod version)

@ProviderFor(LoginDevicesListController)
final loginDevicesListControllerProvider =
    LoginDevicesListControllerProvider._();

/// Controller for login devices (Riverpod version)
final class LoginDevicesListControllerProvider
    extends
        $NotifierProvider<LoginDevicesListController, LoginDevicesListState> {
  /// Controller for login devices (Riverpod version)
  LoginDevicesListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginDevicesListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginDevicesListControllerHash();

  @$internal
  @override
  LoginDevicesListController create() => LoginDevicesListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginDevicesListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginDevicesListState>(value),
    );
  }
}

String _$loginDevicesListControllerHash() =>
    r'087946580440823509501e2d9e92fafc38dc8302';

/// Controller for login devices (Riverpod version)

abstract class _$LoginDevicesListController
    extends $Notifier<LoginDevicesListState> {
  LoginDevicesListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoginDevicesListState, LoginDevicesListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginDevicesListState, LoginDevicesListState>,
              LoginDevicesListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
