// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dyn_create_reserve_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dynamics create reserve controller (Riverpod version)

@ProviderFor(DynCreateReserveController)
final dynCreateReserveControllerProvider = DynCreateReserveControllerFamily._();

/// Dynamics create reserve controller (Riverpod version)
final class DynCreateReserveControllerProvider
    extends
        $NotifierProvider<DynCreateReserveController, DynCreateReserveState> {
  /// Dynamics create reserve controller (Riverpod version)
  DynCreateReserveControllerProvider._({
    required DynCreateReserveControllerFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'dynCreateReserveControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dynCreateReserveControllerHash();

  @override
  String toString() {
    return r'dynCreateReserveControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DynCreateReserveController create() => DynCreateReserveController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynCreateReserveState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynCreateReserveState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DynCreateReserveControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dynCreateReserveControllerHash() =>
    r'3506a23f090af74d429ffbcaba96b1cb04d5151e';

/// Dynamics create reserve controller (Riverpod version)

final class DynCreateReserveControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DynCreateReserveController,
          DynCreateReserveState,
          DynCreateReserveState,
          DynCreateReserveState,
          int?
        > {
  DynCreateReserveControllerFamily._()
    : super(
        retry: null,
        name: r'dynCreateReserveControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Dynamics create reserve controller (Riverpod version)

  DynCreateReserveControllerProvider call(int? sid) =>
      DynCreateReserveControllerProvider._(argument: sid, from: this);

  @override
  String toString() => r'dynCreateReserveControllerProvider';
}

/// Dynamics create reserve controller (Riverpod version)

abstract class _$DynCreateReserveController
    extends $Notifier<DynCreateReserveState> {
  late final _$args = ref.$arg as int?;
  int? get sid => _$args;

  DynCreateReserveState build(int? sid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynCreateReserveState, DynCreateReserveState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynCreateReserveState, DynCreateReserveState>,
              DynCreateReserveState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
