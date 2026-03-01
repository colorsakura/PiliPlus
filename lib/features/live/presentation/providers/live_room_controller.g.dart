// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing live room information

@ProviderFor(LiveRoomController)
final liveRoomControllerProvider = LiveRoomControllerProvider._();

/// Controller for managing live room information
final class LiveRoomControllerProvider
    extends $NotifierProvider<LiveRoomController, LiveRoomState> {
  /// Controller for managing live room information
  LiveRoomControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveRoomControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveRoomControllerHash();

  @$internal
  @override
  LiveRoomController create() => LiveRoomController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveRoomState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveRoomState>(value),
    );
  }
}

String _$liveRoomControllerHash() =>
    r'91e45b08e774c9fb68ff2ffe6dc1665dc6b50715';

/// Controller for managing live room information

abstract class _$LiveRoomController extends $Notifier<LiveRoomState> {
  LiveRoomState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveRoomState, LiveRoomState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveRoomState, LiveRoomState>,
              LiveRoomState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
