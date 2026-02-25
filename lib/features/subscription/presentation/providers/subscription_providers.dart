import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:PiliPlus/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:PiliPlus/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:PiliPlus/features/subscription/presentation/providers/subscription_controller.dart';

// Remote Datasource Provider
final subscriptionRemoteDatasourceProvider =
    Provider<SubscriptionRemoteDatasource>((ref) {
      return const SubscriptionRemoteDatasource();
    });

// Repository Provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final datasource = ref.watch(subscriptionRemoteDatasourceProvider);
  return SubscriptionRepositoryImpl(datasource);
});

// Controller Provider
final subscriptionControllerProvider = Provider<SubscriptionController>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final account = Accounts.main;
  return SubscriptionController(
    repository: repository,
    isLogin: account.isLogin,
  );
});
