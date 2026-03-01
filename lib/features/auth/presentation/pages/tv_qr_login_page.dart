import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/auth/presentation/providers/auth_controller.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

/// TV QR Code Login Page
///
/// Displays a QR code for TV app login and polls for login status
class TVQRLoginPage extends ConsumerWidget {
  const TVQRLoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(tvqrLoginControllerProvider);

    // Listen for successful login
    ref.listen<TVQRLoginState>(
      tvqrLoginControllerProvider,
      (previous, next) {
        if (next.isSuccess) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录成功！'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Navigate to home or pop with result
          // Navigator.of(context).pop(next.loginResult);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('TV扫码登录'),
        actions: [
          if (loginState.isReady || loginState.isPolling)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loginState.isLoading
                  ? null
                  : () {
                      ref.read(tvqrLoginControllerProvider.notifier).refresh();
                    },
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Icon
                _buildStatusIcon(loginState),

                const SizedBox(height: 32),

                // Status Message
                _buildStatusMessage(loginState),

                const SizedBox(height: 48),

                // QR Code or Loading
                _buildContent(loginState, ref),

                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(loginState, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(TVQRLoginState state) {
    IconData icon;
    Color color;

    switch (state.status) {
      case TVQRLoginStatus.initial:
        icon = Icons.qr_code_2;
        color = Colors.blue;
        break;
      case TVQRLoginStatus.loading:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      case TVQRLoginStatus.qrCodeReady:
        icon = Icons.qr_code;
        color = Colors.green;
        break;
      case TVQRLoginStatus.polling:
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case TVQRLoginStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case TVQRLoginStatus.expired:
        icon = Icons.qr_code_2_outlined;
        color = Colors.grey;
        break;
      case TVQRLoginStatus.error:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 80, color: color);
  }

  Widget _buildStatusMessage(TVQRLoginState state) {
    String message;
    String? subMessage;

    switch (state.status) {
      case TVQRLoginStatus.initial:
        message = '点击下方按钮获取登录二维码';
        break;
      case TVQRLoginStatus.loading:
        message = '正在生成二维码...';
        break;
      case TVQRLoginStatus.qrCodeReady:
        message = '请使用哔哩哔哩TV版扫码登录';
        subMessage = '二维码有效期 ${state.remainingSeconds} 秒';
        break;
      case TVQRLoginStatus.polling:
        message = '等待扫码...';
        subMessage = '剩余 ${state.remainingSeconds} 秒';
        break;
      case TVQRLoginStatus.success:
        message = '登录成功！';
        break;
      case TVQRLoginStatus.expired:
        message = '二维码已过期';
        subMessage = '请点击刷新按钮重新获取';
        break;
      case TVQRLoginStatus.error:
        message = state.errorMessage ?? '发生错误';
        subMessage = '请重试';
        break;
    }

    return Column(
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(TVQRLoginState state, WidgetRef ref) {
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }

    if (state.qrCodeUrl != null) {
      return Column(
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: PrettyQrView.data(
                data: state.qrCodeUrl!,
                errorCorrectLevel: QrErrorCorrectLevel.H,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scanning indicator (if polling)
          if (state.isPolling)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('正在检测扫码状态...'),
              ],
            ),
        ],
      );
    }

    if (state.isExpired) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            const Text('二维码已过期，请刷新'),
          ],
        ),
      );
    }

    if (state.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.errorMessage ?? '未知错误',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(TVQRLoginState state, WidgetRef ref) {
    if (state.isInitial || state.hasError || state.isExpired) {
      return ElevatedButton.icon(
        onPressed: state.isLoading
            ? null
            : () {
                ref.read(tvqrLoginControllerProvider.notifier).fetchQRCode();
              },
        icon: const Icon(Icons.qr_code),
        label: const Text('获取二维码'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      );
    }

    if (state.isReady || state.isPolling) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: state.isLoading
                ? null
                : () {
                    ref.read(tvqrLoginControllerProvider.notifier).reset();
                  },
            icon: const Icon(Icons.close),
            label: const Text('取消'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: state.isLoading
                ? null
                : () {
                    ref.read(tvqrLoginControllerProvider.notifier).refresh();
                  },
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
