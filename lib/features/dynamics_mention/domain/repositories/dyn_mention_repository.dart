import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';

/// Repository for dynamic mention operations
///
/// Provides methods for searching users to mention in dynamics.
abstract class DynMentionRepository {
  /// Search for users by keyword to mention in a dynamic post
  ///
  /// Returns a list of mention groups containing matching users.
  Future<LoadingState<List<MentionGroup>?>> searchMentions({String? keyword});
}
