// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing reply lists

@ProviderFor(ReplyListController)
final replyListControllerProvider = ReplyListControllerProvider._();

/// Controller for managing reply lists
final class ReplyListControllerProvider
    extends $NotifierProvider<ReplyListController, ReplyListState> {
  /// Controller for managing reply lists
  ReplyListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'replyListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$replyListControllerHash();

  @$internal
  @override
  ReplyListController create() => ReplyListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReplyListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReplyListState>(value),
    );
  }
}

String _$replyListControllerHash() =>
    r'97d7ca78db671e62f2fe061f6a9549072b0019b2';

/// Controller for managing reply lists

abstract class _$ReplyListController extends $Notifier<ReplyListState> {
  ReplyListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReplyListState, ReplyListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReplyListState, ReplyListState>,
              ReplyListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
