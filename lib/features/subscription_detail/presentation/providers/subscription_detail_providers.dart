import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/models/sub/sub/list.dart';
import 'package:PiliPlus/features/subscription_detail/data/datasources/subscription_detail_remote_datasource.dart';
import 'package:PiliPlus/features/subscription_detail/data/repositories/subscription_detail_repository_impl.dart';
import 'package:PiliPlus/features/subscription_detail/domain/repositories/subscription_detail_repository.dart';
import 'package:PiliPlus/features/subscription_detail/presentation/providers/subscription_detail_controller.dart';

// Remote Datasource Provider
final subscriptionDetailRemoteDatasourceProvider =
    Provider<SubscriptionDetailRemoteDatasource>((ref) {
  return const SubscriptionDetailRemoteDatasource();
});

// Repository Provider
final subscriptionDetailRepositoryProvider = Provider<SubscriptionDetailRepository>((ref) {
  final datasource = ref.watch(subscriptionDetailRemoteDatasourceProvider);
  return SubscriptionDetailRepositoryImpl(datasource);
});

/// Controller parameters
class SubscriptionDetailParams {
  const SubscriptionDetailParams({
    required this.id,
    this.initialSubInfo,
  });

  final int id;
  final SubItemModel? initialSubInfo;
}

// Controller Provider - uses Provider.family for different ids
final subscriptionDetailControllerProvider =
    Provider.family<SubscriptionDetailController, SubscriptionDetailParams>((ref, params) {
  return SubscriptionDetailController(
    id: params.id,
    repository: ref.watch(subscriptionDetailRepositoryProvider),
    initialSubInfo: params.initialSubInfo,
  );
});
