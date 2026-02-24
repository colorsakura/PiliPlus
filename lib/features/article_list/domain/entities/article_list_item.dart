import 'package:PiliPlus/models/article/article_list/article.dart';
import 'package:PiliPlus/models/article/article_list/data.dart';
import 'package:PiliPlus/models/article/article_list/list.dart';
import 'package:PiliPlus/models/model_owner.dart';

/// Article list data entity
///
/// Contains the list info, author, and articles
class ArticleListDataEntity {
  /// List information (name, cover, stats, etc.)
  final ArticleListInfo? info;

  /// Author information
  final Owner? author;

  /// List of articles in the collection
  final List<ArticleListItemModel> items;

  const ArticleListDataEntity({
    this.info,
    this.author,
    this.items = const [],
  });

  /// Create entity from API response
  factory ArticleListDataEntity.fromModel(ArticleListData model) {
    return ArticleListDataEntity(
      info: model.list,
      author: model.author,
      items: model.articles ?? [],
    );
  }
}
