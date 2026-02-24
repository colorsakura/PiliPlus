import 'package:PiliPlus/models/space/space_article/item.dart';

/// Entity for member article items
///
/// This is a simple wrapper around the existing SpaceArticleItem model.
/// In a full migration, this would be a pure domain object without
/// dependencies on data layer models.
typedef MemberArticleItemEntity = SpaceArticleItem;
