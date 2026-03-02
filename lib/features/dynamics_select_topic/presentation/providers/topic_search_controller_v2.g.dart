// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_search_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for dynamics topic selection functionality (Riverpod version)
///
/// Manages searching for topics and tracking pagination state.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.

@ProviderFor(TopicSearchController)
final topicSearchControllerProvider = TopicSearchControllerProvider._();

/// Controller for dynamics topic selection functionality (Riverpod version)
///
/// Manages searching for topics and tracking pagination state.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.
final class TopicSearchControllerProvider
    extends $NotifierProvider<TopicSearchController, TopicSearchState> {
  /// Controller for dynamics topic selection functionality (Riverpod version)
  ///
  /// Manages searching for topics and tracking pagination state.
  /// Note: FocusNode and TextEditingController should be managed by the UI layer.
  TopicSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topicSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topicSearchControllerHash();

  @$internal
  @override
  TopicSearchController create() => TopicSearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TopicSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TopicSearchState>(value),
    );
  }
}

String _$topicSearchControllerHash() =>
    r'bd85e1576aa4fb5effd793200a2345eafd93bb54';

/// Controller for dynamics topic selection functionality (Riverpod version)
///
/// Manages searching for topics and tracking pagination state.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.

abstract class _$TopicSearchController extends $Notifier<TopicSearchState> {
  TopicSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TopicSearchState, TopicSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TopicSearchState, TopicSearchState>,
              TopicSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
