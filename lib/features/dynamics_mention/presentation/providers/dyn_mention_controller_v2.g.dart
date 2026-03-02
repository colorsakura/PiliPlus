// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dyn_mention_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for dynamics mention functionality (Riverpod version)
///
/// Manages searching for users to mention and tracking selected mentions.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.

@ProviderFor(DynMentionController)
final dynMentionControllerProvider = DynMentionControllerProvider._();

/// Controller for dynamics mention functionality (Riverpod version)
///
/// Manages searching for users to mention and tracking selected mentions.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.
final class DynMentionControllerProvider
    extends $NotifierProvider<DynMentionController, DynMentionState> {
  /// Controller for dynamics mention functionality (Riverpod version)
  ///
  /// Manages searching for users to mention and tracking selected mentions.
  /// Note: FocusNode and TextEditingController should be managed by the UI layer.
  DynMentionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynMentionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dynMentionControllerHash();

  @$internal
  @override
  DynMentionController create() => DynMentionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynMentionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynMentionState>(value),
    );
  }
}

String _$dynMentionControllerHash() =>
    r'fdf4aac2a0a257f143bde1f1513c2a4e0056302a';

/// Controller for dynamics mention functionality (Riverpod version)
///
/// Manages searching for users to mention and tracking selected mentions.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.

abstract class _$DynMentionController extends $Notifier<DynMentionState> {
  DynMentionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynMentionState, DynMentionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynMentionState, DynMentionState>,
              DynMentionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
