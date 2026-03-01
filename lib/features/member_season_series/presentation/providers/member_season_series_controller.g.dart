// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_season_series_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member season series list (Riverpod version)

@ProviderFor(MemberSeasonSeriesController)
final memberSeasonSeriesControllerProvider =
    MemberSeasonSeriesControllerFamily._();

/// Controller for member season series list (Riverpod version)
final class MemberSeasonSeriesControllerProvider
    extends
        $NotifierProvider<
          MemberSeasonSeriesController,
          MemberSeasonSeriesState
        > {
  /// Controller for member season series list (Riverpod version)
  MemberSeasonSeriesControllerProvider._({
    required MemberSeasonSeriesControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberSeasonSeriesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberSeasonSeriesControllerHash();

  @override
  String toString() {
    return r'memberSeasonSeriesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberSeasonSeriesController create() => MemberSeasonSeriesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberSeasonSeriesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberSeasonSeriesState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberSeasonSeriesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberSeasonSeriesControllerHash() =>
    r'cbb0c90d7d7a3cef60594a6df6e16283ff8fe487';

/// Controller for member season series list (Riverpod version)

final class MemberSeasonSeriesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberSeasonSeriesController,
          MemberSeasonSeriesState,
          MemberSeasonSeriesState,
          MemberSeasonSeriesState,
          int
        > {
  MemberSeasonSeriesControllerFamily._()
    : super(
        retry: null,
        name: r'memberSeasonSeriesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member season series list (Riverpod version)

  MemberSeasonSeriesControllerProvider call(int mid) =>
      MemberSeasonSeriesControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberSeasonSeriesControllerProvider';
}

/// Controller for member season series list (Riverpod version)

abstract class _$MemberSeasonSeriesController
    extends $Notifier<MemberSeasonSeriesState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberSeasonSeriesState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<MemberSeasonSeriesState, MemberSeasonSeriesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberSeasonSeriesState, MemberSeasonSeriesState>,
              MemberSeasonSeriesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
