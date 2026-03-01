// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_coin_arc_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member coin arc list (Riverpod version)

@ProviderFor(MemberCoinArcController)
final memberCoinArcControllerProvider = MemberCoinArcControllerFamily._();

/// Controller for member coin arc list (Riverpod version)
final class MemberCoinArcControllerProvider
    extends $NotifierProvider<MemberCoinArcController, MemberCoinArcState> {
  /// Controller for member coin arc list (Riverpod version)
  MemberCoinArcControllerProvider._({
    required MemberCoinArcControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberCoinArcControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberCoinArcControllerHash();

  @override
  String toString() {
    return r'memberCoinArcControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberCoinArcController create() => MemberCoinArcController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberCoinArcState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberCoinArcState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberCoinArcControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberCoinArcControllerHash() =>
    r'a527bfda3350c3e1050c3b02ef09ac834a77eef5';

/// Controller for member coin arc list (Riverpod version)

final class MemberCoinArcControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberCoinArcController,
          MemberCoinArcState,
          MemberCoinArcState,
          MemberCoinArcState,
          int
        > {
  MemberCoinArcControllerFamily._()
    : super(
        retry: null,
        name: r'memberCoinArcControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member coin arc list (Riverpod version)

  MemberCoinArcControllerProvider call(int mid) =>
      MemberCoinArcControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberCoinArcControllerProvider';
}

/// Controller for member coin arc list (Riverpod version)

abstract class _$MemberCoinArcController extends $Notifier<MemberCoinArcState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberCoinArcState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberCoinArcState, MemberCoinArcState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberCoinArcState, MemberCoinArcState>,
              MemberCoinArcState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
