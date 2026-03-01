// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_cheese_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member cheese list (Riverpod version)

@ProviderFor(MemberCheeseController)
final memberCheeseControllerProvider = MemberCheeseControllerFamily._();

/// Controller for member cheese list (Riverpod version)
final class MemberCheeseControllerProvider
    extends $NotifierProvider<MemberCheeseController, MemberCheeseState> {
  /// Controller for member cheese list (Riverpod version)
  MemberCheeseControllerProvider._({
    required MemberCheeseControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberCheeseControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberCheeseControllerHash();

  @override
  String toString() {
    return r'memberCheeseControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberCheeseController create() => MemberCheeseController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberCheeseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberCheeseState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberCheeseControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberCheeseControllerHash() =>
    r'91b97270b2b669226320329be15196ae45cb32fa';

/// Controller for member cheese list (Riverpod version)

final class MemberCheeseControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberCheeseController,
          MemberCheeseState,
          MemberCheeseState,
          MemberCheeseState,
          int
        > {
  MemberCheeseControllerFamily._()
    : super(
        retry: null,
        name: r'memberCheeseControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member cheese list (Riverpod version)

  MemberCheeseControllerProvider call(int mid) =>
      MemberCheeseControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberCheeseControllerProvider';
}

/// Controller for member cheese list (Riverpod version)

abstract class _$MemberCheeseController extends $Notifier<MemberCheeseState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberCheeseState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberCheeseState, MemberCheeseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberCheeseState, MemberCheeseState>,
              MemberCheeseState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
