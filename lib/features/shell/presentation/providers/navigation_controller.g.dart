// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 导航控制器
///
/// 管理导航选中状态的简化控制器

@ProviderFor(Navigation)
final navigationProvider = NavigationProvider._();

/// 导航控制器
///
/// 管理导航选中状态的简化控制器
final class NavigationProvider
    extends $NotifierProvider<Navigation, NavigationState> {
  /// 导航控制器
  ///
  /// 管理导航选中状态的简化控制器
  NavigationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationHash();

  @$internal
  @override
  Navigation create() => Navigation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationState>(value),
    );
  }
}

String _$navigationHash() => r'31f66afcf888bb83e782d4e7d13c0294cd8f723d';

/// 导航控制器
///
/// 管理导航选中状态的简化控制器

abstract class _$Navigation extends $Notifier<NavigationState> {
  NavigationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NavigationState, NavigationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NavigationState, NavigationState>,
              NavigationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
