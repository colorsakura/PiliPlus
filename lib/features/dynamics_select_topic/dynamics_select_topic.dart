/// Dynamics topic selection feature
///
/// Provides functionality for searching and selecting topics for dynamic posts.

// Domain exports
export 'domain/usecases/search_topics.dart';

// Presentation (ChangeNotifier - Legacy)
export 'presentation/providers/topic_search_providers.dart' show searchTopicsProvider;

// Presentation (Riverpod - New)
export 'presentation/providers/topic_search_controller_v2.dart';
export 'presentation/pages/select_topic_page_v2.dart';

// Pages
export 'presentation/pages/select_topic_page.dart';

// Widgets
export 'presentation/widgets/topic_item.dart';
