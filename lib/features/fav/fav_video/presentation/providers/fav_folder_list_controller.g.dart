// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fav_folder_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing favorite folders

@ProviderFor(FavFolderListController)
final favFolderListControllerProvider = FavFolderListControllerProvider._();

/// Controller for managing favorite folders
final class FavFolderListControllerProvider
    extends $NotifierProvider<FavFolderListController, FavFolderListState> {
  /// Controller for managing favorite folders
  FavFolderListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favFolderListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favFolderListControllerHash();

  @$internal
  @override
  FavFolderListController create() => FavFolderListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavFolderListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavFolderListState>(value),
    );
  }
}

String _$favFolderListControllerHash() =>
    r'eab20c728bb62eaf30d8b52ab87036c1560d6fb1';

/// Controller for managing favorite folders

abstract class _$FavFolderListController extends $Notifier<FavFolderListState> {
  FavFolderListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavFolderListState, FavFolderListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavFolderListState, FavFolderListState>,
              FavFolderListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
