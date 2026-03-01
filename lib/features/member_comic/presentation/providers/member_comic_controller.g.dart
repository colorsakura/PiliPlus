// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_comic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for member comic list (Riverpod version)

@ProviderFor(MemberComicController)
final memberComicControllerProvider = MemberComicControllerFamily._();

/// Controller for member comic list (Riverpod version)
final class MemberComicControllerProvider
    extends $NotifierProvider<MemberComicController, MemberComicState> {
  /// Controller for member comic list (Riverpod version)
  MemberComicControllerProvider._({
    required MemberComicControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberComicControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberComicControllerHash();

  @override
  String toString() {
    return r'memberComicControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemberComicController create() => MemberComicController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberComicState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberComicState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemberComicControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberComicControllerHash() =>
    r'e0906f92699504519b9bdfb899d7c6f2711c9eea';

/// Controller for member comic list (Riverpod version)

final class MemberComicControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MemberComicController,
          MemberComicState,
          MemberComicState,
          MemberComicState,
          int
        > {
  MemberComicControllerFamily._()
    : super(
        retry: null,
        name: r'memberComicControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for member comic list (Riverpod version)

  MemberComicControllerProvider call(int mid) =>
      MemberComicControllerProvider._(argument: mid, from: this);

  @override
  String toString() => r'memberComicControllerProvider';
}

/// Controller for member comic list (Riverpod version)

abstract class _$MemberComicController extends $Notifier<MemberComicState> {
  late final _$args = ref.$arg as int;
  int get mid => _$args;

  MemberComicState build(int mid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MemberComicState, MemberComicState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemberComicState, MemberComicState>,
              MemberComicState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
