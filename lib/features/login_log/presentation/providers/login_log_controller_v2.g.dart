// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_log_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for login log (Riverpod version)

@ProviderFor(LoginLogController)
final loginLogControllerProvider = LoginLogControllerProvider._();

/// Controller for login log (Riverpod version)
final class LoginLogControllerProvider
    extends $NotifierProvider<LoginLogController, LoginLogState> {
  /// Controller for login log (Riverpod version)
  LoginLogControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginLogControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginLogControllerHash();

  @$internal
  @override
  LoginLogController create() => LoginLogController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginLogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginLogState>(value),
    );
  }
}

String _$loginLogControllerHash() =>
    r'd39a77a4b0aeb5b95398c3ea4122e9b4e71e4b45';

/// Controller for login log (Riverpod version)

abstract class _$LoginLogController extends $Notifier<LoginLogState> {
  LoginLogState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoginLogState, LoginLogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginLogState, LoginLogState>,
              LoginLogState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
