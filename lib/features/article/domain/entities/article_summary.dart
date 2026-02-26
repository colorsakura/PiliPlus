import 'package:PiliPlus/models/model_avatar.dart';

/// Article summary entity for clean architecture
class ArticleSummaryEntity {
  final Avatar? author;
  final String? title;
  final String? cover;

  const ArticleSummaryEntity({
    this.author,
    this.title,
    this.cover,
  });
}
