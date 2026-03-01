// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 简化的登录控制器（用于演示干净架构）

@ProviderFor(SimpleLoginController)
final simpleLoginControllerProvider = SimpleLoginControllerProvider._();

/// 简化的登录控制器（用于演示干净架构）
final class SimpleLoginControllerProvider
    extends $NotifierProvider<SimpleLoginController, SimpleLoginState> {
  /// 简化的登录控制器（用于演示干净架构）
  SimpleLoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'simpleLoginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$simpleLoginControllerHash();

  @$internal
  @override
  SimpleLoginController create() => SimpleLoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SimpleLoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SimpleLoginState>(value),
    );
  }
}

String _$simpleLoginControllerHash() =>
    r'4174b2d406230b73b762b37c8fb5f37ee0b2c1a7';

/// 简化的登录控制器（用于演示干净架构）

abstract class _$SimpleLoginController extends $Notifier<SimpleLoginState> {
  SimpleLoginState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SimpleLoginState, SimpleLoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SimpleLoginState, SimpleLoginState>,
              SimpleLoginState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
