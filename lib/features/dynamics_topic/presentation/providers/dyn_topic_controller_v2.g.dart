// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dyn_topic_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for dynamics topic functionality (Riverpod version)
///
/// Manages topic details, feed list, and user interactions (favorite, like).

@ProviderFor(DynTopicController)
final dynTopicControllerProvider = DynTopicControllerFamily._();

/// Controller for dynamics topic functionality (Riverpod version)
///
/// Manages topic details, feed list, and user interactions (favorite, like).
final class DynTopicControllerProvider
    extends $NotifierProvider<DynTopicController, DynTopicState> {
  /// Controller for dynamics topic functionality (Riverpod version)
  ///
  /// Manages topic details, feed list, and user interactions (favorite, like).
  DynTopicControllerProvider._({
    required DynTopicControllerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'dynTopicControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dynTopicControllerHash();

  @override
  String toString() {
    return r'dynTopicControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  DynTopicController create() => DynTopicController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynTopicState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynTopicState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DynTopicControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dynTopicControllerHash() =>
    r'ecfd8c6f4dde4ccd3840959eac0c42683d121762';

/// Controller for dynamics topic functionality (Riverpod version)
///
/// Manages topic details, feed list, and user interactions (favorite, like).

final class DynTopicControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DynTopicController,
          DynTopicState,
          DynTopicState,
          DynTopicState,
          (String, String)
        > {
  DynTopicControllerFamily._()
    : super(
        retry: null,
        name: r'dynTopicControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for dynamics topic functionality (Riverpod version)
  ///
  /// Manages topic details, feed list, and user interactions (favorite, like).

  DynTopicControllerProvider call(String topicId, String topicName) =>
      DynTopicControllerProvider._(argument: (topicId, topicName), from: this);

  @override
  String toString() => r'dynTopicControllerProvider';
}

/// Controller for dynamics topic functionality (Riverpod version)
///
/// Manages topic details, feed list, and user interactions (favorite, like).

abstract class _$DynTopicController extends $Notifier<DynTopicState> {
  late final _$args = ref.$arg as (String, String);
  String get topicId => _$args.$1;
  String get topicName => _$args.$2;

  DynTopicState build(String topicId, String topicName);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynTopicState, DynTopicState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynTopicState, DynTopicState>,
              DynTopicState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
