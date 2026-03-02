// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for follow page functionality (Riverpod version)
///
/// Manages follow-up tags with CRUD operations:
/// - Query follow-up tags for current user
/// - Create new tags
/// - Update tag names
/// - Delete tags

@ProviderFor(FollowController)
final followControllerProvider = FollowControllerFamily._();

/// Controller for follow page functionality (Riverpod version)
///
/// Manages follow-up tags with CRUD operations:
/// - Query follow-up tags for current user
/// - Create new tags
/// - Update tag names
/// - Delete tags
final class FollowControllerProvider
    extends $NotifierProvider<FollowController, FollowState> {
  /// Controller for follow page functionality (Riverpod version)
  ///
  /// Manages follow-up tags with CRUD operations:
  /// - Query follow-up tags for current user
  /// - Create new tags
  /// - Update tag names
  /// - Delete tags
  FollowControllerProvider._({
    required FollowControllerFamily super.from,
    required (int, bool, String?) super.argument,
  }) : super(
         retry: null,
         name: r'followControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followControllerHash();

  @override
  String toString() {
    return r'followControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FollowController create() => FollowController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FollowControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followControllerHash() => r'8c7e2c7bba86c2d8015b8fe974bf03e5e74dc5f4';

/// Controller for follow page functionality (Riverpod version)
///
/// Manages follow-up tags with CRUD operations:
/// - Query follow-up tags for current user
/// - Create new tags
/// - Update tag names
/// - Delete tags

final class FollowControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowController,
          FollowState,
          FollowState,
          FollowState,
          (int, bool, String?)
        > {
  FollowControllerFamily._()
    : super(
        retry: null,
        name: r'followControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for follow page functionality (Riverpod version)
  ///
  /// Manages follow-up tags with CRUD operations:
  /// - Query follow-up tags for current user
  /// - Create new tags
  /// - Update tag names
  /// - Delete tags

  FollowControllerProvider call(int mid, bool isOwner, String? userName) =>
      FollowControllerProvider._(
        argument: (mid, isOwner, userName),
        from: this,
      );

  @override
  String toString() => r'followControllerProvider';
}

/// Controller for follow page functionality (Riverpod version)
///
/// Manages follow-up tags with CRUD operations:
/// - Query follow-up tags for current user
/// - Create new tags
/// - Update tag names
/// - Delete tags

abstract class _$FollowController extends $Notifier<FollowState> {
  late final _$args = ref.$arg as (int, bool, String?);
  int get mid => _$args.$1;
  bool get isOwner => _$args.$2;
  String? get userName => _$args.$3;

  FollowState build(int mid, bool isOwner, String? userName);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FollowState, FollowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FollowState, FollowState>,
              FollowState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2, _$args.$3));
  }
}
