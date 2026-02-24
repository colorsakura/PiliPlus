import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_audio/data/repositories/member_audio_repository_impl.dart';
import 'package:PiliPlus/features/member_audio/domain/usecases/fetch_member_audios.dart';
import 'package:PiliPlus/features/member_audio/presentation/providers/member_audio_list_controller.dart';

/// Repository provider
final memberAudioRepositoryProvider = Provider<MemberAudioRepositoryImpl>((
  ref,
) {
  return const MemberAudioRepositoryImpl();
});

/// Use case provider
final fetchMemberAudiosUseCaseProvider = Provider<FetchMemberAudiosUseCase>(
  (ref) {
    return FetchMemberAudiosUseCase(
      ref.watch(memberAudioRepositoryProvider),
    );
  },
);

/// Controller provider (parameterized by member ID)
final memberAudioListControllerProvider =
    Provider.family<MemberAudioListController, int>((ref, mid) {
      return MemberAudioListController(
        mid: mid,
        fetchAudios: ref.watch(fetchMemberAudiosUseCaseProvider),
      );
    });
