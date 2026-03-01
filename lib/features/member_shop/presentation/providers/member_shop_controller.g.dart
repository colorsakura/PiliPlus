// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_shop_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member shop items list (Riverpod version)

@ProviderFor(MemberShopController)
final memberShopControllerProvider = MemberShopControllerFamily._();

/// Controller for member shop items list (Riverpod version)
final class MemberShopControllerProvider
    extends $NotifierProvider<MemberShopController, MemberShopState> {
  /// Controller for member shop items list (Riverpod version)
  MemberShopControllerProvider._({
    required MemberShopControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberShopControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberShopControllerHash();

  @override
  String toString() {
    return r'memberShopControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberShopController create() => MemberShopController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberShopState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberShopState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberShopControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberShopControllerHash() =>
    r'175fc9ada065b9e1fb6ad373b2abea34f9a4c1af';

/// Controller for member shop items list (Riverpod version)

final class MemberShopControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberShopController,
          MemberShopState,
          MemberShopState,
          MemberShopState,
          int
        > {
  MemberShopControllerFamily._()
    : super(
        retry: null,
        name: r'memberShopControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member shop items list (Riverpod version)

  MemberShopControllerProvider call(int mid) =>
      MemberShopControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberShopControllerProvider';
}

/// Controller for member shop items list (Riverpod version)

abstract class _$MemberShopController extends $Notifier<MemberShopState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberShopState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberShopState, MemberShopState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberShopState, MemberShopState>,
              MemberShopState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
