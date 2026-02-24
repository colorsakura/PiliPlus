import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';

/// Remote data source for dynamic mentions
///
/// Fetches mention data from the Bilibili API.
class DynMentionRemoteDatasource {
  /// Search for users to mention by keyword
  ///
  /// [keyword] - The search keyword to filter users
  /// Returns a loading state with list of mention groups
  Future<LoadingState<List<MentionGroup>?>> searchMentions({String? keyword}) {
    return DynamicsHttp.dynMention(keyword: keyword);
  }
}
