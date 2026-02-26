import 'package:PiliPlus/features/sponsor_block/domain/entities/sponsor_user_info.dart';
import 'package:PiliPlus/features/sponsor_block/domain/repositories/sponsor_block_repository.dart';

/// Get user info use case
class GetSponsorUserInfo {
  final SponsorBlockRepository repository;

  const GetSponsorUserInfo(this.repository);

  Future<SponsorUserInfoEntity> call(
    List<String> query, {
    String? userId,
  }) {
    return repository.getUserInfo(
      query,
      userId: userId,
    );
  }
}
