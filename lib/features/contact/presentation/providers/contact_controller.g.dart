// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 联系人页面控制器

@ProviderFor(ContactController)
final contactControllerProvider = ContactControllerProvider._();

/// 联系人页面控制器
final class ContactControllerProvider
    extends $NotifierProvider<ContactController, ContactConfig> {
  /// 联系人页面控制器
  ContactControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactControllerHash();

  @$internal
  @override
  ContactController create() => ContactController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactConfig>(value),
    );
  }
}

String _$contactControllerHash() => r'd7a60c2a80dcd359887d8680f1481412fceb510c';

/// 联系人页面控制器

abstract class _$ContactController extends $Notifier<ContactConfig> {
  ContactConfig build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ContactConfig, ContactConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactConfig, ContactConfig>,
              ContactConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
