/// PGC Review Feature
///
/// 提供PGC内容评论功能
library;

// Riverpod implementation (new - v2)
export 'package:PiliPlus/features/pgc_review/presentation/providers/pgc_review_providers.dart';
export 'package:PiliPlus/features/pgc_review/presentation/providers/pgc_review_controller.dart';
export 'package:PiliPlus/features/pgc_review/presentation/pages/pgc_review_page_v2.dart';

// GetX implementation (deprecated, for backward compatibility)
export 'package:PiliPlus/pages/pgc_review/child/view.dart' show PgcReviewChildPage;
// Note: PgcReviewController in child/controller.dart conflicts with v2 version

