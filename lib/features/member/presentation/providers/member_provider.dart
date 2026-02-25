import 'package:PiliPlus/features/member/presentation/providers/member_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parameters for member page
class MemberParams {
  const MemberParams({
    required this.mid,
    this.fromViewAid,
  });

  final int mid;
  final String? fromViewAid;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberParams &&
          runtimeType == other.runtimeType &&
          other.mid == mid &&
          other.fromViewAid == fromViewAid;

  @override
  int get hashCode => mid.hashCode ^ fromViewAid.hashCode;
}

/// Member controller provider family (keyed by mid and fromViewAid)
final memberControllerProvider =
    Provider.family<MemberController, MemberParams>((ref, params) {
      return MemberController(
        mid: params.mid,
        ref: ref,
        fromViewAid: params.fromViewAid,
      );
    });
