// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_contribute_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member contribute page (Riverpod version)
///
/// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)

@ProviderFor(MemberContributeController)
final memberContributeControllerProvider = MemberContributeControllerFamily._();

/// Controller for member contribute page (Riverpod version)
///
/// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)
final class MemberContributeControllerProvider
    extends
        $NotifierProvider<MemberContributeController, MemberContributeState> {
  /// Controller for member contribute page (Riverpod version)
  ///
  /// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)
  MemberContributeControllerProvider._({
    required MemberContributeControllerFamily super.from,
    required (SpaceTab2, bool, int?) super.argument,
  }) : super(
         retry: null,
         name: r'memberContributeControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberContributeControllerHash();

  @override
  String toString() {
    return r'memberContributeControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MemberContributeController create() => MemberContributeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberContributeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberContributeState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberContributeControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberContributeControllerHash() =>
    r'674372538918085d7cd46f54d429ea4de3339302';

/// Controller for member contribute page (Riverpod version)
///
/// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)

final class MemberContributeControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberContributeController,
          MemberContributeState,
          MemberContributeState,
          MemberContributeState,
          (SpaceTab2, bool, int?)
        > {
  MemberContributeControllerFamily._()
    : super(
        retry: null,
        name: r'memberContributeControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member contribute page (Riverpod version)
  ///
  /// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)

  MemberContributeControllerProvider call(
    SpaceTab2 contributeTab,
    bool hasSeasonOrSeries,
    int? initialIndex,
  ) => MemberContributeControllerProvider._(
    argument: (contributeTab, hasSeasonOrSeries, initialIndex),
    from: this,
  );

  @override
  String toString() => r'memberContributeControllerProvider';
}

/// Controller for member contribute page (Riverpod version)
///
/// Manages tab navigation for user's contributed content (videos, articles, audio, etc.)

abstract class _$MemberContributeController
    extends $Notifier<MemberContributeState> {
  late final _$args = ref.$arg as (SpaceTab2, bool, int?);
  SpaceTab2 get contributeTab => _$args.$1;
  bool get hasSeasonOrSeries => _$args.$2;
  int? get initialIndex => _$args.$3;

  MemberContributeState build(
    SpaceTab2 contributeTab,
    bool hasSeasonOrSeries,
    int? initialIndex,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberContributeState, MemberContributeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberContributeState, MemberContributeState>,
              MemberContributeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2, _$args.$3));
  }
}
