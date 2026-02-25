import 'package:PiliPlus/models/dynamics/vote_model.dart';

/// State for vote creation form
///
/// Manages the form state for creating or editing votes in dynamic posts.
class VoteFormState {
  final String title;
  final String description;
  final int voteType; // 0 = text, 1 = image
  final List<Option> options;
  final int choiceCount; // 1 = single select, >1 = multi select
  final DateTime endTime;
  final bool canCreate;
  final String formKey;

  VoteFormState({
    this.title = '',
    this.description = '',
    this.voteType = 0,
    List<Option>? options,
    this.choiceCount = 1,
    required this.endTime,
    this.canCreate = false,
    this.formKey = '',
  }) : options =
           options ??
           [
             Option(optDesc: '', imgUrl: ''),
             Option(optDesc: '', imgUrl: ''),
           ];

  VoteFormState copyWith({
    String? title,
    String? description,
    int? voteType,
    List<Option>? options,
    int? choiceCount,
    DateTime? endTime,
    bool? canCreate,
    String? formKey,
  }) {
    return VoteFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      voteType: voteType ?? this.voteType,
      options: options ?? this.options,
      choiceCount: choiceCount ?? this.choiceCount,
      endTime: endTime ?? this.endTime,
      canCreate: canCreate ?? this.canCreate,
      formKey: formKey ?? this.formKey,
    );
  }
}
