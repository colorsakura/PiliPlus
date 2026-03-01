// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_audio_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member audio list (Riverpod version)

@ProviderFor(MemberAudioController)
final memberAudioControllerProvider = MemberAudioControllerFamily._();

/// Controller for member audio list (Riverpod version)
final class MemberAudioControllerProvider
    extends $NotifierProvider<MemberAudioController, MemberAudioState> {
  /// Controller for member audio list (Riverpod version)
  MemberAudioControllerProvider._({
    required MemberAudioControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberAudioControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberAudioControllerHash();

  @override
  String toString() {
    return r'memberAudioControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberAudioController create() => MemberAudioController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberAudioState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberAudioState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberAudioControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberAudioControllerHash() =>
    r'516802e6580fb15cbf6823fa9b3f01c92fac2888';

/// Controller for member audio list (Riverpod version)

final class MemberAudioControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberAudioController,
          MemberAudioState,
          MemberAudioState,
          MemberAudioState,
          int
        > {
  MemberAudioControllerFamily._()
    : super(
        retry: null,
        name: r'memberAudioControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member audio list (Riverpod version)

  MemberAudioControllerProvider call(int mid) =>
      MemberAudioControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberAudioControllerProvider';
}

/// Controller for member audio list (Riverpod version)

abstract class _$MemberAudioController extends $Notifier<MemberAudioState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberAudioState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberAudioState, MemberAudioState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberAudioState, MemberAudioState>,
              MemberAudioState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
