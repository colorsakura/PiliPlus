import 'package:PiliPlus/features/dynamics_create_vote/data/datasources/vote_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_create_vote/data/repositories/vote_repository_impl.dart';
import 'package:PiliPlus/features/dynamics_create_vote/domain/repositories/vote_repository.dart';
import 'package:PiliPlus/features/dynamics_create_vote/domain/usecases/vote_use_cases.dart';
import 'package:PiliPlus/features/dynamics_create_vote/presentation/providers/vote_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the vote remote data source
final voteRemoteDatasourceProvider = Provider<VoteRemoteDatasource>((ref) {
  return VoteRemoteDatasource();
});

/// Provider for the vote repository
final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  final remoteDatasource = ref.watch(voteRemoteDatasourceProvider);
  return VoteRepositoryImpl(remoteDatasource: remoteDatasource);
});

/// Provider for the create vote use case
final createVoteProvider = Provider<CreateVote>((ref) {
  final repository = ref.watch(voteRepositoryProvider);
  return CreateVote(repository);
});

/// Provider for the get vote info use case
final getVoteInfoProvider = Provider<GetVoteInfo>((ref) {
  final repository = ref.watch(voteRepositoryProvider);
  return GetVoteInfo(repository);
});

/// Provider for the upload vote image use case
final uploadVoteImageProvider = Provider<UploadVoteImage>((ref) {
  final repository = ref.watch(voteRepositoryProvider);
  return UploadVoteImage(repository);
});

/// Provider for the vote controller
///
/// [voteId] - Optional vote ID for editing existing votes
final voteControllerProvider = ChangeNotifierProvider.family<VoteController, int?>(
  (ref, voteId) {
    final createVote = ref.watch(createVoteProvider);
    final getVoteInfo = ref.watch(getVoteInfoProvider);
    final uploadVoteImage = ref.watch(uploadVoteImageProvider);

    final controller = VoteController(
      createVote,
      getVoteInfo,
      uploadVoteImage,
      voteId,
    );

    // Initialize if editing
    controller.initialize();

    return controller;
  },
);
