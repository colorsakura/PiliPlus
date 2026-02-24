import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:get/get.dart';

/// Controller for search result page (GetX version for backward compatibility)
///
/// This controller manages:
/// - Search keyword from route parameters
/// - Result count for each search type tab
/// - Scroll-to-top functionality
///
/// Note: This is kept for backward compatibility. The page still uses GetX.
/// TODO: Migrate to Riverpod when search panels are migrated
class SearchResultController extends GetxController {
  String keyword = Get.parameters['keyword'] ?? '';

  RxList<int> count = List.filled(SearchType.values.length, -1).obs;

  RxInt toTopIndex = (-1).obs;

  @override
  void onClose() {
    toTopIndex.close();
    super.onClose();
  }
}
