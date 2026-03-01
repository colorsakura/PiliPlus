// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_user_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for follow search (Riverpod version)

@ProviderFor(FollowUserSearchController)
final followUserSearchControllerProvider =
    FollowUserSearchControllerProvider._();

/// Controller for follow search (Riverpod version)
final class FollowUserSearchControllerProvider
    extends
        $NotifierProvider<FollowUserSearchController, FollowUserSearchState> {
  /// Controller for follow search (Riverpod version)
  FollowUserSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followUserSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followUserSearchControllerHash();

  @$internal
  @override
  FollowUserSearchController create() => FollowUserSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowUserSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowUserSearchState>(value),
    );
  }
}

String _$followUserSearchControllerHash() =>
    r'943b5a472b7658d27889d3dac908e4687e68aa58';

/// Controller for follow search (Riverpod version)

abstract class _$FollowUserSearchController
    extends $Notifier<FollowUserSearchState> {
  FollowUserSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FollowUserSearchState, FollowUserSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FollowUserSearchState, FollowUserSearchState>,
              FollowUserSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
