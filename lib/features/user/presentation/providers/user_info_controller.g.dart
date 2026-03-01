// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing user information

@ProviderFor(UserInfoController)
final userInfoControllerProvider = UserInfoControllerProvider._();

/// Controller for managing user information
final class UserInfoControllerProvider
    extends $NotifierProvider<UserInfoController, UserInfoState> {
  /// Controller for managing user information
  UserInfoControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userInfoControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userInfoControllerHash();

  @$internal
  @override
  UserInfoController create() => UserInfoController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserInfoState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserInfoState>(value),
    );
  }
}

String _$userInfoControllerHash() =>
    r'87a27c990567defa2c2db63dfa7b543fc0918c5c';

/// Controller for managing user information

abstract class _$UserInfoController extends $Notifier<UserInfoState> {
  UserInfoState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserInfoState, UserInfoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserInfoState, UserInfoState>,
              UserInfoState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
