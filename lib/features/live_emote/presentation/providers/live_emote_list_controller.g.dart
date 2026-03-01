// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_emote_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for live emote (Riverpod version with family parameter)

@ProviderFor(LiveEmoteListController)
final liveEmoteListControllerProvider = LiveEmoteListControllerFamily._();

/// Controller for live emote (Riverpod version with family parameter)
final class LiveEmoteListControllerProvider
    extends $NotifierProvider<LiveEmoteListController, LiveEmoteListState> {
  /// Controller for live emote (Riverpod version with family parameter)
  LiveEmoteListControllerProvider._({
    required LiveEmoteListControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'liveEmoteListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveEmoteListControllerHash();

  @override
  String toString() {
    return r'liveEmoteListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveEmoteListController create() => LiveEmoteListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveEmoteListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveEmoteListState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveEmoteListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveEmoteListControllerHash() =>
    r'c7493e64c3aa226e2b48a136d24584519661de87';

/// Controller for live emote (Riverpod version with family parameter)

final class LiveEmoteListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveEmoteListController,
          LiveEmoteListState,
          LiveEmoteListState,
          LiveEmoteListState,
          int
        > {
  LiveEmoteListControllerFamily._()
    : super(
        retry: null,
        name: r'liveEmoteListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for live emote (Riverpod version with family parameter)

  LiveEmoteListControllerProvider call(int roomId) =>
      LiveEmoteListControllerProvider._(argument: roomId, from: this);

  @override
  String toString() => r'liveEmoteListControllerProvider';
}

/// Controller for live emote (Riverpod version with family parameter)

abstract class _$LiveEmoteListController extends $Notifier<LiveEmoteListState> {
  late final _$args = ref.$arg as int;
  int get roomId => _$args;

  LiveEmoteListState build(int roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveEmoteListState, LiveEmoteListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveEmoteListState, LiveEmoteListState>,
              LiveEmoteListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
