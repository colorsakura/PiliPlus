import 'package:PiliPlus/features/search_result/presentation/providers/search_result_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller provider for search result
///
/// Uses NotifierProvider for state management
final searchResultControllerProvider =
    NotifierProvider<SearchResultController, SearchResultState>(
      SearchResultController.new,
    );
