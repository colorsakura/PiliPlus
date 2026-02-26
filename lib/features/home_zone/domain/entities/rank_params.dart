/// Parameters for fetching rank video list
enum RankType {
  /// General video rank by partition ID
  byPartition,
  /// PGC (Professional Generated Content) rank list
  pgc,
  /// PGC season rank list
  pgcSeason,
}

/// Parameters for fetching rank video list
class FetchRankParams {
  final RankType type;
  final int? rid; // Partition ID (required for byPartition type)
  final int? seasonType; // Season type (required for pgc/pgcSeason)

  const FetchRankParams({
    required this.type,
    this.rid,
    this.seasonType,
  });

  /// Create params for partition-based rank
  const FetchRankParams.byPartition(int rid)
    : type = RankType.byPartition,
      rid = rid,
      seasonType = null;

  /// Create params for PGC rank
  const FetchRankParams.pgc(int seasonType)
    : type = RankType.pgc,
      rid = null,
      seasonType = seasonType;

  /// Create params for PGC season rank
  const FetchRankParams.pgcSeason(int? seasonType)
    : type = RankType.pgcSeason,
      rid = null,
      seasonType = seasonType;
}
