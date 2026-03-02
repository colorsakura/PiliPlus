// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_controller_v2.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for vote creation functionality (Riverpod version)
///
/// Manages the vote creation form state and operations.

@ProviderFor(VoteController)
final voteControllerProvider = VoteControllerFamily._();

/// Controller for vote creation functionality (Riverpod version)
///
/// Manages the vote creation form state and operations.
final class VoteControllerProvider
    extends $NotifierProvider<VoteController, VoteFormState> {
  /// Controller for vote creation functionality (Riverpod version)
  ///
  /// Manages the vote creation form state and operations.
  VoteControllerProvider._({
    required VoteControllerFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'voteControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$voteControllerHash();

  @override
  String toString() {
    return r'voteControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VoteController create() => VoteController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VoteFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VoteFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VoteControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$voteControllerHash() => r'6c15f2232b75345ab00ede863bd11050643fc5e8';

/// Controller for vote creation functionality (Riverpod version)
///
/// Manages the vote creation form state and operations.

final class VoteControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VoteController,
          VoteFormState,
          VoteFormState,
          VoteFormState,
          int?
        > {
  VoteControllerFamily._()
    : super(
        retry: null,
        name: r'voteControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for vote creation functionality (Riverpod version)
  ///
  /// Manages the vote creation form state and operations.

  VoteControllerProvider call(int? voteId) =>
      VoteControllerProvider._(argument: voteId, from: this);

  @override
  String toString() => r'voteControllerProvider';
}

/// Controller for vote creation functionality (Riverpod version)
///
/// Manages the vote creation form state and operations.

abstract class _$VoteController extends $Notifier<VoteFormState> {
  late final _$args = ref.$arg as int?;
  int? get voteId => _$args;

  VoteFormState build(int? voteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VoteFormState, VoteFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VoteFormState, VoteFormState>,
              VoteFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
