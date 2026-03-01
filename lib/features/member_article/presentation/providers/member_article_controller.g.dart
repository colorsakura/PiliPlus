// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_article_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member article list (Riverpod version)

@ProviderFor(MemberArticleController)
final memberArticleControllerProvider = MemberArticleControllerFamily._();

/// Controller for member article list (Riverpod version)
final class MemberArticleControllerProvider
    extends $NotifierProvider<MemberArticleController, MemberArticleState> {
  /// Controller for member article list (Riverpod version)
  MemberArticleControllerProvider._({
    required MemberArticleControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberArticleControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberArticleControllerHash();

  @override
  String toString() {
    return r'memberArticleControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberArticleController create() => MemberArticleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberArticleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberArticleState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberArticleControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberArticleControllerHash() =>
    r'1e366a3bb7098c9d3b83547d76f91312ab931ae0';

/// Controller for member article list (Riverpod version)

final class MemberArticleControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberArticleController,
          MemberArticleState,
          MemberArticleState,
          MemberArticleState,
          int
        > {
  MemberArticleControllerFamily._()
    : super(
        retry: null,
        name: r'memberArticleControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member article list (Riverpod version)

  MemberArticleControllerProvider call(int mid) =>
      MemberArticleControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberArticleControllerProvider';
}

/// Controller for member article list (Riverpod version)

abstract class _$MemberArticleController extends $Notifier<MemberArticleState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberArticleState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberArticleState, MemberArticleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberArticleState, MemberArticleState>,
              MemberArticleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
