// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_like_arc_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member like arc list (Riverpod version)

@ProviderFor(MemberLikeArcController)
final memberLikeArcControllerProvider = MemberLikeArcControllerFamily._();

/// Controller for member like arc list (Riverpod version)
final class MemberLikeArcControllerProvider
    extends $NotifierProvider<MemberLikeArcController, MemberLikeArcState> {
  /// Controller for member like arc list (Riverpod version)
  MemberLikeArcControllerProvider._({
    required MemberLikeArcControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberLikeArcControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberLikeArcControllerHash();

  @override
  String toString() {
    return r'memberLikeArcControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberLikeArcController create() => MemberLikeArcController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberLikeArcState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberLikeArcState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberLikeArcControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberLikeArcControllerHash() =>
    r'87def15fc7c7598cb3637882689b6f8d1a955461';

/// Controller for member like arc list (Riverpod version)

final class MemberLikeArcControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberLikeArcController,
          MemberLikeArcState,
          MemberLikeArcState,
          MemberLikeArcState,
          int
        > {
  MemberLikeArcControllerFamily._()
    : super(
        retry: null,
        name: r'memberLikeArcControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member like arc list (Riverpod version)

  MemberLikeArcControllerProvider call(int mid) =>
      MemberLikeArcControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberLikeArcControllerProvider';
}

/// Controller for member like arc list (Riverpod version)

abstract class _$MemberLikeArcController extends $Notifier<MemberLikeArcState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberLikeArcState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberLikeArcState, MemberLikeArcState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberLikeArcState, MemberLikeArcState>,
              MemberLikeArcState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
