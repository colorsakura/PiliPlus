// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msg_unread_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing message unread counts

@ProviderFor(MsgUnreadController)
final msgUnreadControllerProvider = MsgUnreadControllerProvider._();

/// Controller for managing message unread counts
final class MsgUnreadControllerProvider
    extends $NotifierProvider<MsgUnreadController, MsgUnreadState> {
  /// Controller for managing message unread counts
  MsgUnreadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'msgUnreadControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$msgUnreadControllerHash();

  @$internal
  @override
  MsgUnreadController create() => MsgUnreadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MsgUnreadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MsgUnreadState>(value),
    );
  }
}

String _$msgUnreadControllerHash() =>
    r'a26fe1c4c0af3451df84c32d32a5ac09e831ea08';

/// Controller for managing message unread counts

abstract class _$MsgUnreadController extends $Notifier<MsgUnreadState> {
  MsgUnreadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MsgUnreadState, MsgUnreadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MsgUnreadState, MsgUnreadState>,
              MsgUnreadState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
