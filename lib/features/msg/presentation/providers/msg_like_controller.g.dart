// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msg_like_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing like messages

@ProviderFor(MsgLikeController)
final msgLikeControllerProvider = MsgLikeControllerProvider._();

/// Controller for managing like messages
final class MsgLikeControllerProvider
    extends $NotifierProvider<MsgLikeController, MsgLikeState> {
  /// Controller for managing like messages
  MsgLikeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'msgLikeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$msgLikeControllerHash();

  @$internal
  @override
  MsgLikeController create() => MsgLikeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MsgLikeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MsgLikeState>(value),
    );
  }
}

String _$msgLikeControllerHash() => r'7cd33eee4e4b72b39f04ead3b6d5dfacc8a84e12';

/// Controller for managing like messages

abstract class _$MsgLikeController extends $Notifier<MsgLikeState> {
  MsgLikeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MsgLikeState, MsgLikeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MsgLikeState, MsgLikeState>,
              MsgLikeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
