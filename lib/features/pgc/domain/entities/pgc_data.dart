import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// PGC data entity
///
/// Contains the three data sources for PGC page
class PgcDataEntity {
  /// Main PGC index list
  final List<PgcIndexItem>? items;

  /// User's followed PGC list
  final List<FavPgcItemModel>? followItems;

  /// PGC timeline data
  final List<TimelineResult>? timeline;

  const PgcDataEntity({
    this.items,
    this.followItems,
    this.timeline,
  });
}
