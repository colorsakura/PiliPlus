import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:get/get.dart';

/// Controller for search result page (GetX version for backward compatibility)
///
/// This controller manages:
/// - Search keyword from route parameters
/// - Result count for each search type tab
/// - Scroll-to-top functionality
///
/// Note: This is kept for backward compatibility with search_panel controllers.
/// TODO: Remove after search_panel is migrated to Riverpod
class SearchResultController extends GetxController {
  SearchResultController({required this.tag});

  final String tag;

  String keyword = Get.parameters['keyword'] ?? '';

  RxList<int> count = List.filled(SearchType.values.length, -1).obs;

  RxInt toTopIndex = (-1).obs;

  /// Set count at specific index
  void setCountAtIndex(int index, int value) {
    count[index] = value;
  }

  @override
  void onClose() {
    toTopIndex.close();
    super.onClose();
  }
}
