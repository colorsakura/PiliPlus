// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pgc_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PGC controller (Riverpod version)
///
/// Manages PGC page state with three data sources

@ProviderFor(PgcController)
final pgcControllerProvider = PgcControllerFamily._();

/// PGC controller (Riverpod version)
///
/// Manages PGC page state with three data sources
final class PgcControllerProvider
    extends $NotifierProvider<PgcController, PgcState> {
  /// PGC controller (Riverpod version)
  ///
  /// Manages PGC page state with three data sources
  PgcControllerProvider._({
    required PgcControllerFamily super.from,
    required HomeTabType super.argument,
  }) : super(
         retry: null,
         name: r'pgcControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pgcControllerHash();

  @override
  String toString() {
    return r'pgcControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PgcController create() => PgcController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PgcState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PgcState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PgcControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pgcControllerHash() => r'83af6e44134318916be81cb00f90b7d29ee043e3';

/// PGC controller (Riverpod version)
///
/// Manages PGC page state with three data sources

final class PgcControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PgcController,
          PgcState,
          PgcState,
          PgcState,
          HomeTabType
        > {
  PgcControllerFamily._()
    : super(
        retry: null,
        name: r'pgcControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PGC controller (Riverpod version)
  ///
  /// Manages PGC page state with three data sources

  PgcControllerProvider call(HomeTabType tabType) =>
      PgcControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'pgcControllerProvider';
}

/// PGC controller (Riverpod version)
///
/// Manages PGC page state with three data sources

abstract class _$PgcController extends $Notifier<PgcState> {
  late final _$args = ref.$arg as HomeTabType;
  HomeTabType get tabType => _$args;

  PgcState build(HomeTabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PgcState, PgcState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PgcState, PgcState>,
              PgcState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
