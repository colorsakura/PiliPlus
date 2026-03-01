// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_upower_rank_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member upower rank list (Riverpod version)

@ProviderFor(MemberUpowerRankController)
final memberUpowerRankControllerProvider = MemberUpowerRankControllerFamily._();

/// Controller for member upower rank list (Riverpod version)
final class MemberUpowerRankControllerProvider
    extends
        $NotifierProvider<MemberUpowerRankController, MemberUpowerRankState> {
  /// Controller for member upower rank list (Riverpod version)
  MemberUpowerRankControllerProvider._({
    required MemberUpowerRankControllerFamily super.from,
    required (String, int?) super.argument,
  }) : super(
         retry: null,
         name: r'memberUpowerRankControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberUpowerRankControllerHash();

  @override
  String toString() {
    return r'memberUpowerRankControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MemberUpowerRankController create() => MemberUpowerRankController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberUpowerRankState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberUpowerRankState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberUpowerRankControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberUpowerRankControllerHash() =>
    r'a46030457df467f361dbcaf5c98ba7df3a4a1fc1';

/// Controller for member upower rank list (Riverpod version)

final class MemberUpowerRankControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberUpowerRankController,
          MemberUpowerRankState,
          MemberUpowerRankState,
          MemberUpowerRankState,
          (String, int?)
        > {
  MemberUpowerRankControllerFamily._()
    : super(
        retry: null,
        name: r'memberUpowerRankControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member upower rank list (Riverpod version)

  MemberUpowerRankControllerProvider call(String upMid, int? privilegeType) =>
      MemberUpowerRankControllerProvider._(
        argument: (upMid, privilegeType),
        from: this,
      );

  @override
  String toString() => r'memberUpowerRankControllerProvider';
}

/// Controller for member upower rank list (Riverpod version)

abstract class _$MemberUpowerRankController
    extends $Notifier<MemberUpowerRankState> {
  late final _$args = ref.$arg as (String, int?);
  String get upMid => _$args.$1;
  int? get privilegeType => _$args.$2;

  MemberUpowerRankState build(String upMid, int? privilegeType);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberUpowerRankState, MemberUpowerRankState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberUpowerRankState, MemberUpowerRankState>,
              MemberUpowerRankState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
