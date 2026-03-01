// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_dm_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for live danmaku block page (Riverpod version with family)
///
/// Manages danmaku shield settings for live rooms:
/// - Shield levels (level, rank, verify)
/// - Shield keywords
/// - Shielded users
/// - Enable/disable all shields

@ProviderFor(LiveDmFilterController)
final liveDmFilterControllerProvider = LiveDmFilterControllerFamily._();

/// Controller for live danmaku block page (Riverpod version with family)
///
/// Manages danmaku shield settings for live rooms:
/// - Shield levels (level, rank, verify)
/// - Shield keywords
/// - Shielded users
/// - Enable/disable all shields
final class LiveDmFilterControllerProvider
    extends $NotifierProvider<LiveDmFilterController, LiveDmBlockState> {
  /// Controller for live danmaku block page (Riverpod version with family)
  ///
  /// Manages danmaku shield settings for live rooms:
  /// - Shield levels (level, rank, verify)
  /// - Shield keywords
  /// - Shielded users
  /// - Enable/disable all shields
  LiveDmFilterControllerProvider._({
    required LiveDmFilterControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveDmFilterControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveDmFilterControllerHash();

  @override
  String toString() {
    return r'liveDmFilterControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveDmFilterController create() => LiveDmFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveDmBlockState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveDmBlockState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveDmFilterControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveDmFilterControllerHash() =>
    r'd1a0de009619788a61f1d7f0855b3f27fa011233';

/// Controller for live danmaku block page (Riverpod version with family)
///
/// Manages danmaku shield settings for live rooms:
/// - Shield levels (level, rank, verify)
/// - Shield keywords
/// - Shielded users
/// - Enable/disable all shields

final class LiveDmFilterControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveDmFilterController,
          LiveDmBlockState,
          LiveDmBlockState,
          LiveDmBlockState,
          String
        > {
  LiveDmFilterControllerFamily._()
    : super(
        retry: null,
        name: r'liveDmFilterControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for live danmaku block page (Riverpod version with family)
  ///
  /// Manages danmaku shield settings for live rooms:
  /// - Shield levels (level, rank, verify)
  /// - Shield keywords
  /// - Shielded users
  /// - Enable/disable all shields

  LiveDmFilterControllerProvider call(String roomId) =>
      LiveDmFilterControllerProvider._(argument: roomId, from: this);

  @override
  String toString() => r'liveDmFilterControllerProvider';
}

/// Controller for live danmaku block page (Riverpod version with family)
///
/// Manages danmaku shield settings for live rooms:
/// - Shield levels (level, rank, verify)
/// - Shield keywords
/// - Shielded users
/// - Enable/disable all shields

abstract class _$LiveDmFilterController extends $Notifier<LiveDmBlockState> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  LiveDmBlockState build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveDmBlockState, LiveDmBlockState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveDmBlockState, LiveDmBlockState>,
              LiveDmBlockState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
