// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whisper_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing whisper sessions

@ProviderFor(WhisperSessionController)
final whisperSessionControllerProvider = WhisperSessionControllerProvider._();

/// Controller for managing whisper sessions
final class WhisperSessionControllerProvider
    extends $NotifierProvider<WhisperSessionController, WhisperSessionState> {
  /// Controller for managing whisper sessions
  WhisperSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whisperSessionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whisperSessionControllerHash();

  @$internal
  @override
  WhisperSessionController create() => WhisperSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhisperSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhisperSessionState>(value),
    );
  }
}

String _$whisperSessionControllerHash() =>
    r'12d823a68bb611184f446232d03527884a203313';

/// Controller for managing whisper sessions

abstract class _$WhisperSessionController
    extends $Notifier<WhisperSessionState> {
  WhisperSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WhisperSessionState, WhisperSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WhisperSessionState, WhisperSessionState>,
              WhisperSessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
