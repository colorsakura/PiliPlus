// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dyn_topic_rcmd_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dynamics topic recommendation controller (Riverpod version)

@ProviderFor(DynTopicRcmdController)
final dynTopicRcmdControllerProvider = DynTopicRcmdControllerProvider._();

/// Dynamics topic recommendation controller (Riverpod version)
final class DynTopicRcmdControllerProvider
    extends $NotifierProvider<DynTopicRcmdController, DynTopicRcmdState> {
  /// Dynamics topic recommendation controller (Riverpod version)
  DynTopicRcmdControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynTopicRcmdControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dynTopicRcmdControllerHash();

  @$internal
  @override
  DynTopicRcmdController create() => DynTopicRcmdController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynTopicRcmdState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynTopicRcmdState>(value),
    );
  }
}

String _$dynTopicRcmdControllerHash() =>
    r'c759fed98b9a93e3836e87eb4165fa4b006a1ff8';

/// Dynamics topic recommendation controller (Riverpod version)

abstract class _$DynTopicRcmdController extends $Notifier<DynTopicRcmdState> {
  DynTopicRcmdState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynTopicRcmdState, DynTopicRcmdState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynTopicRcmdState, DynTopicRcmdState>,
              DynTopicRcmdState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
