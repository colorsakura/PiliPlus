import 'package:PiliPlus/features/dynamics_create_vote/domain/entities/vote_form_state.dart';
import 'package:PiliPlus/features/dynamics_create_vote/domain/usecases/vote_use_cases.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/vote_model.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';

/// Controller for vote creation functionality
///
/// Manages the vote creation form state and operations.
class VoteController extends ChangeNotifier {
  final CreateVote _createVote;
  final GetVoteInfo _getVoteInfo;
  final UploadVoteImage _uploadVoteImage;

  final int? voteId;
  final DateTime now = DateTime.now();
  late final DateTime maxEndDate = now.copyWith(day: now.day + 90);

  VoteFormState _state = VoteFormState(
    endTime: DateTime.now().add(const Duration(days: 1)),
  );

  VoteController(
    this._createVote,
    this._getVoteInfo,
    this._uploadVoteImage,
    this.voteId,
  );

  VoteFormState get state => _state;

  /// Initialize the form
  ///
  /// If voteId is provided, loads existing vote data.
  Future<void> initialize() async {
    if (voteId != null) {
      final result = await _getVoteInfo(voteId!);
      if (result case Success(:final response)) {
        _updateState(VoteFormState(
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
        ));
      }
      // Error handling is done by the UI layer
    }
  }

  /// Update the vote title
  void updateTitle(String value) {
    _updateState(_state.copyWith(title: value));
    _validateForm();
  }

  /// Update the vote description
  void updateDescription(String value) {
    _updateState(_state.copyWith(description: value));
  }

  /// Update the vote type (0=text, 1=image)
  void updateVoteType(int value) {
    _updateState(_state.copyWith(voteType: value));
    _validateForm();
  }

  /// Update the choice count (1=single, >1=multi)
  void updateChoiceCount(int value) {
    _updateState(_state.copyWith(choiceCount: value));
  }

  /// Update the end time
  void updateEndTime(DateTime value) {
    _updateState(_state.copyWith(endTime: value));
  }

  /// Add a new option
  void addOption() {
    final newOptions = List<Option>.from(_state.options)
      ..add(Option(optDesc: '', imgUrl: ''));
    _updateState(_state.copyWith(options: newOptions));
    _validateForm();
  }

  /// Remove an option
  void removeOption(int index) {
    final newOptions = List<Option>.from(_state.options)..removeAt(index);
    final newChoiceCount =
        _state.choiceCount > newOptions.length ? newOptions.length : _state.choiceCount;
    _updateState(_state.copyWith(
      options: newOptions,
      choiceCount: newChoiceCount,
    ));
    _validateForm();
  }

  /// Update an option description
  void updateOptionDesc(int index, String value) {
    final newOptions = List<Option>.from(_state.options);
    newOptions[index] = Option(
      optDesc: value,
      imgUrl: newOptions[index].imgUrl,
    );
    _updateState(_state.copyWith(options: newOptions));
    _validateForm();
  }

  /// Upload an image for an option
  Future<void> uploadOptionImage(int index, String path) async {
    final result = await _uploadVoteImage(index, path);
    if (result case Success(:final response)) {
      final newOptions = List<Option>.from(_state.options);
      newOptions[index] = Option(
        optDesc: newOptions[index].optDesc,
        imgUrl: response ?? '',
      );
      _updateState(_state.copyWith(options: newOptions));
      _validateForm();
    }
    // Error handling is done by the UI layer
  }

  /// Create or update the vote
  Future<LoadingState<int?>> createVote() async {
    final voteInfo = VoteInfo(
      title: _state.title,
      desc: _state.description,
      type: _state.voteType,
      duration: _state.endTime.difference(now).inSeconds,
      options: _state.options,
      onlyFansLevel: 0,
      choiceCnt: _state.choiceCount,
      votePublisher: Accounts.main.mid,
      voteId: voteId,
    );

    return _createVote(voteInfo);
  }

  /// Validate the form and update canCreate state
  void _validateForm() {
    bool canCreate;

    if (_state.voteType == 0) {
      // Text vote: just need title and all option descriptions
      canCreate = _state.title.isNotEmpty &&
          _state.options.every((e) => e.optDesc?.isNotEmpty == true);
    } else {
      // Image vote: need title, all option descriptions, and all images
      canCreate = _state.title.isNotEmpty &&
          _state.options.every((e) =>
              e.optDesc?.isNotEmpty == true && e.imgUrl?.isNotEmpty == true);
    }

    _updateState(_state.copyWith(canCreate: canCreate));
  }

  void _updateState(VoteFormState newState) {
    _state = newState;
    notifyListeners();
  }
}
