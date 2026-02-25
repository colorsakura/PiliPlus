import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_contribute/presentation/providers/member_contribute_controller.dart';

/// Provider for MemberContributeController
///
/// Uses Provider.family to create unique controllers for each (heroTag, initialIndex) combination
final memberContributeControllerProvider =
    Provider.family<MemberContributeController, _MemberContributeParams>(
      (ref, params) {
        return MemberContributeController(
          contributeTab: params.contributeTab,
          hasSeasonOrSeries: params.hasSeasonOrSeries,
          initialIndex: params.initialIndex,
        );
      },
    );

/// Parameters for MemberContributeController
class _MemberContributeParams {
  const _MemberContributeParams({
    required this.contributeTab,
    required this.hasSeasonOrSeries,
    this.initialIndex,
  });

  final dynamic contributeTab;
  final bool hasSeasonOrSeries;
  final int? initialIndex;
}
