import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/mixins/list_controller_mixin.dart';

/// Example simple list controller using the new mixin
///
/// This demonstrates how to use BaseListController for a simple paginated list.
class ExampleListController extends BaseListController<String> {
  @override
  Future<LoadingState<List<String>>> fetchData(int page) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate end of data after page 3
    if (page >= 3) {
      return const Success([]);
    }

    // Return dummy data
    final items = List.generate(
      20,
      (index) => 'Item ${(page - 1) * 20 + index + 1}',
    );

    return Success(items);
  }
}

/// Provider for the example controller
final exampleListControllerProvider =
    NotifierProvider<ExampleListController, LoadingState<List<String>?>>(
      ExampleListController.new,
    );
