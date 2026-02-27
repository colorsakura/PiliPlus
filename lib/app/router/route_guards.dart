import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route guard for protecting routes that require login
class RouteGuard {
  RouteGuard._();

  static const _loginRequiredRoutes = <String>{
    // Add routes that require login here
    // Example: AppRoutes.subscription, AppRoutes.memberDynamics
  };

  /// Check if route requires login
  static bool _needsLogin(String path) {
    return _loginRequiredRoutes.any((route) => path.startsWith(route));
  }

  /// Redirect function for go_router
  static String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;

    // Check if route requires login and user is not logged in
    if (_needsLogin(path) && !Accounts.main.isLogin) {
      return AppRoutes.loginPage;
    }

    // No redirect needed
    return null;
  }
}
