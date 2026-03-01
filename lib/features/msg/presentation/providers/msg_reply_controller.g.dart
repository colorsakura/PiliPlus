// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msg_reply_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing reply messages

@ProviderFor(MsgReplyController)
final msgReplyControllerProvider = MsgReplyControllerProvider._();

/// Controller for managing reply messages
final class MsgReplyControllerProvider
    extends $NotifierProvider<MsgReplyController, MsgReplyState> {
  /// Controller for managing reply messages
  MsgReplyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'msgReplyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$msgReplyControllerHash();

  @$internal
  @override
  MsgReplyController create() => MsgReplyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MsgReplyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MsgReplyState>(value),
    );
  }
}

String _$msgReplyControllerHash() =>
    r'9462bbfa96b4964bae4b10c76504b06f87fcb640';

/// Controller for managing reply messages

abstract class _$MsgReplyController extends $Notifier<MsgReplyState> {
  MsgReplyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MsgReplyState, MsgReplyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MsgReplyState, MsgReplyState>,
              MsgReplyState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
