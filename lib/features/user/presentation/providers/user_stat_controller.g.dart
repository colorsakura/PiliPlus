// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing user statistics

@ProviderFor(UserStatController)
final userStatControllerProvider = UserStatControllerProvider._();

/// Controller for managing user statistics
final class UserStatControllerProvider
    extends $NotifierProvider<UserStatController, UserStatState> {
  /// Controller for managing user statistics
  UserStatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStatControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStatControllerHash();

  @$internal
  @override
  UserStatController create() => UserStatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStatState>(value),
    );
  }
}

String _$userStatControllerHash() =>
    r'86d5af9d779e331b5610b06d75567ecc5c1e6308';

/// Controller for managing user statistics

abstract class _$UserStatController extends $Notifier<UserStatState> {
  UserStatState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserStatState, UserStatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserStatState, UserStatState>,
              UserStatState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
