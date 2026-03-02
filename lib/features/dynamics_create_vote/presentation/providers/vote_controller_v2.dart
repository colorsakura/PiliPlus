import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/dynamics_create_vote/domain/entities/vote_form_state.dart';
import 'package:PiliPlus/features/dynamics_create_vote/domain/usecases/vote_use_cases.dart';
import 'package:PiliPlus/features/dynamics_create_vote/presentation/providers/vote_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/vote_model.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/utils.dart';

part 'vote_controller_v2.g.dart';

/// Controller for vote creation functionality (Riverpod version)
///
/// Manages the vote creation form state and operations.
@riverpod
class VoteController extends _$VoteController {
  final DateTime now = DateTime.now();
  late final DateTime maxEndDate = now.copyWith(day: now.day + 90);

  @override
  VoteFormState build(int? voteId) {
    // Initialize form with default end time
    return VoteFormState(
      endTime: DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// Initialize the form
  ///
  /// If voteId is provided, loads existing vote data.
  Future<void> initialize(int? voteId) async {
    if (voteId != null) {
      final getVoteInfo = ref.read(getVoteInfoProvider);
      final result = await getVoteInfo(voteId);
      if (result case Success(:final response)) {
        state = VoteFormState(
          title: response.title ?? '',
          description: response.desc ?? '',
          voteType: response.options.first.imgUrl?.isNotEmpty == true ? 1 : 0,
          options: response.options,
          choiceCount: response.choiceCnt ?? 1,
          endTime: DateTime.fromMillisecondsSinceEpoch(
            response.endTime! * 1000,
          ),
          canCreate: true,
          formKey: Utils.generateRandomString(6),
        );
      }
      // Error handling is done by the UI layer
    }
  }

  /// Update the vote title
  void updateTitle(String value) {
    state = state.copyWith(title: value);
    _validateForm();
  }

  /// Update the vote description
  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  /// Update the vote type (0=text, 1=image)
  void updateVoteType(int value) {
    state = state.copyWith(voteType: value);
    _validateForm();
  }

  /// Update the choice count (1=single, >1=multi)
  void updateChoiceCount(int value) {
    state = state.copyWith(choiceCount: value);
  }

  /// Update the end time
  void updateEndTime(DateTime value) {
    state = state.copyWith(endTime: value);
  }

  /// Add a new option
  void addOption() {
    final newOptions = List<Option>.from(state.options)
      ..add(Option(optDesc: '', imgUrl: ''));
    state = state.copyWith(options: newOptions);
    _validateForm();
  }

  /// Remove an option
  void removeOption(int index) {
    final newOptions = List<Option>.from(state.options)..removeAt(index);
    final newChoiceCount = state.choiceCount > newOptions.length
        ? newOptions.length
        : state.choiceCount;
    state = state.copyWith(
      options: newOptions,
      choiceCount: newChoiceCount,
    );
    _validateForm();
  }

  /// Update an option description
  void updateOptionDesc(int index, String value) {
    final newOptions = List<Option>.from(state.options);
    newOptions[index] = Option(
      optDesc: value,
      imgUrl: newOptions[index].imgUrl,
    );
    state = state.copyWith(options: newOptions);
    _validateForm();
  }

  /// Upload an image for an option
  Future<void> uploadOptionImage(int index, String path) async {
    final uploadVoteImage = ref.read(uploadVoteImageProvider);
    final result = await uploadVoteImage(index, path);
    if (result case Success(:final response)) {
      final newOptions = List<Option>.from(state.options);
      newOptions[index] = Option(
        optDesc: newOptions[index].optDesc,
        imgUrl: response ?? '',
      );
      state = state.copyWith(options: newOptions);
      _validateForm();
    }
    // Error handling is done by the UI layer
  }

  /// Create or update the vote
  Future<LoadingState<int?>> createVote(int? voteId) async {
    final createVote = ref.read(createVoteProvider);
    final voteInfo = VoteInfo(
      title: state.title,
      desc: state.description,
      type: state.voteType,
      duration: state.endTime.difference(now).inSeconds,
      options: state.options,
      onlyFansLevel: 0,
      choiceCnt: state.choiceCount,
      votePublisher: Accounts.main.mid,
      voteId: voteId,
    );

    return createVote(voteInfo);
  }

  /// Validate the form and update canCreate state
  void _validateForm() {
    bool canCreate;

    if (state.voteType == 0) {
      // Text vote: just need title and all option descriptions
      canCreate = state.title.isNotEmpty &&
          state.options.every((e) => e.optDesc?.isNotEmpty == true);
    } else {
      // Image vote: need title, all option descriptions, and all images
      canCreate = state.title.isNotEmpty &&
          state.options.every(
            (e) => e.optDesc?.isNotEmpty == true && e.imgUrl?.isNotEmpty == true,
          );
    }

    state = state.copyWith(canCreate: canCreate);
  }
}
