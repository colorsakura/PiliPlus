import 'package:PiliPlus/models/later/data.dart';
import 'package:PiliPlus/features/user/domain/entities/user_params.dart';
import 'package:PiliPlus/features/user/domain/repositories/user_repository.dart';

/// Use case for fetching "See You Later" (watch later) list
class FetchSeeYouLater {
  final UserRepository repository;

  const FetchSeeYouLater(this.repository);

  Future<LaterData> call(FetchSeeYouLaterParams params) =>
      repository.fetchSeeYouLater(params);
}
