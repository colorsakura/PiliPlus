import 'package:PiliPlus/models/dynamics/result.dart';

/// Dynamics item entity.
///
/// This is a simplified wrapper around the existing model.
/// For a full migration, this would be a pure entity with no model dependencies.
class DynamicItemEntity {
  const DynamicItemEntity({
    required this.model,
  });

  /// The underlying model.
  /// TODO: Convert to pure entity with separate fields
  final DynamicItemModel model;

  /// ID string of the dynamic.
  String get idStr => model.idStr.toString();

  /// Type of the dynamic.
  String? get type => model.type;

  /// Modules containing dynamic content.
  ItemModulesModel get modules => model.modules;

  /// Original dynamic (for reposted content).
  DynamicItemModel? get orig => model.orig;

  /// Basic information.
  Basic? get basic => model.basic;

  /// Visibility settings.
  bool? get visible => model.visible;
}
