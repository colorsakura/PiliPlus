// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whisper_link_setting_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for whisper link settings (Riverpod version)

@ProviderFor(WhisperLinkSettingController)
final whisperLinkSettingControllerProvider =
    WhisperLinkSettingControllerFamily._();

/// Controller for whisper link settings (Riverpod version)
final class WhisperLinkSettingControllerProvider
    extends
        $NotifierProvider<
          WhisperLinkSettingController,
          WhisperLinkSettingState
        > {
  /// Controller for whisper link settings (Riverpod version)
  WhisperLinkSettingControllerProvider._({
    required WhisperLinkSettingControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'whisperLinkSettingControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$whisperLinkSettingControllerHash();

  @override
  String toString() {
    return r'whisperLinkSettingControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WhisperLinkSettingController create() => WhisperLinkSettingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhisperLinkSettingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhisperLinkSettingState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WhisperLinkSettingControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$whisperLinkSettingControllerHash() =>
    r'31fc6502badd78e217f060a194b99337bc693fe9';

/// Controller for whisper link settings (Riverpod version)

final class WhisperLinkSettingControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          WhisperLinkSettingController,
          WhisperLinkSettingState,
          WhisperLinkSettingState,
          WhisperLinkSettingState,
          int
        > {
  WhisperLinkSettingControllerFamily._()
    : super(
        retry: null,
        name: r'whisperLinkSettingControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for whisper link settings (Riverpod version)

  WhisperLinkSettingControllerProvider call(int talkerUid) =>
      WhisperLinkSettingControllerProvider._(argument: talkerUid, from: this);

  @override
  String toString() => r'whisperLinkSettingControllerProvider';
}

/// Controller for whisper link settings (Riverpod version)

abstract class _$WhisperLinkSettingController
    extends $Notifier<WhisperLinkSettingState> {
  late final _$args = ref.$arg as int;
  int get talkerUid => _$args;

  WhisperLinkSettingState build(int talkerUid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<WhisperLinkSettingState, WhisperLinkSettingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WhisperLinkSettingState, WhisperLinkSettingState>,
              WhisperLinkSettingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
