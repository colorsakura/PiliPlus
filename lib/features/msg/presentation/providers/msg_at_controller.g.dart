// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msg_at_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing at messages

@ProviderFor(MsgAtController)
final msgAtControllerProvider = MsgAtControllerProvider._();

/// Controller for managing at messages
final class MsgAtControllerProvider
    extends $NotifierProvider<MsgAtController, MsgAtState> {
  /// Controller for managing at messages
  MsgAtControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'msgAtControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$msgAtControllerHash();

  @$internal
  @override
  MsgAtController create() => MsgAtController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MsgAtState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MsgAtState>(value),
    );
  }
}

String _$msgAtControllerHash() => r'54b7bd1e6ec7d871a0820f2339b19afd8c54b1bd';

/// Controller for managing at messages

abstract class _$MsgAtController extends $Notifier<MsgAtState> {
  MsgAtState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MsgAtState, MsgAtState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MsgAtState, MsgAtState>,
              MsgAtState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
