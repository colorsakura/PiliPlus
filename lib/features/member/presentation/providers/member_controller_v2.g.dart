// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member page functionality (Riverpod version)
///
/// Manages member space information, follow status, and user interactions.

@ProviderFor(MemberController)
final memberControllerProvider = MemberControllerFamily._();

/// Controller for member page functionality (Riverpod version)
///
/// Manages member space information, follow status, and user interactions.
final class MemberControllerProvider
    extends $NotifierProvider<MemberController, MemberState> {
  /// Controller for member page functionality (Riverpod version)
  ///
  /// Manages member space information, follow status, and user interactions.
  MemberControllerProvider._({
    required MemberControllerFamily super.from,
    required (int, {String? fromViewAid}) super.argument,
  }) : super(
         retry: null,
         name: r'memberControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberControllerHash();

  @override
  String toString() {
    return r'memberControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MemberController create() => MemberController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberControllerHash() => r'8d3912391c4db43c74ed47a540398b0de64b161b';

/// Controller for member page functionality (Riverpod version)
///
/// Manages member space information, follow status, and user interactions.

final class MemberControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberController,
          MemberState,
          MemberState,
          MemberState,
          (int, {String? fromViewAid})
        > {
  MemberControllerFamily._()
    : super(
        retry: null,
        name: r'memberControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member page functionality (Riverpod version)
  ///
  /// Manages member space information, follow status, and user interactions.

  MemberControllerProvider call(int mid, {String? fromViewAid}) =>
      MemberControllerProvider._(
        argument: (mid, fromViewAid: fromViewAid),
        from: this,
      );

  @override
  String toString() => r'memberControllerProvider';
}

/// Controller for member page functionality (Riverpod version)
///
/// Manages member space information, follow status, and user interactions.

abstract class _$MemberController extends $Notifier<MemberState> {
  late final _$args = ref.$arg as (int, {String? fromViewAid});
  int get mid => _$args.$1;
  String? get fromViewAid => _$args.fromViewAid;

  MemberState build(int mid, {String? fromViewAid});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberState, MemberState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberState, MemberState>,
              MemberState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(_$args.$1, fromViewAid: _$args.fromViewAid),
    );
  }
}
