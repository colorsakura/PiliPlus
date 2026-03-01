import 'dart:async';

import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/auth/domain/entities/auth_params.dart';
import 'package:PiliPlus/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TV QR Code Login Status
enum TVQRLoginStatus {
  initial,
  loading,
  qrCodeReady,
  polling,
  success,
  error,
  expired,
}

/// TV QR Code Login State
class TVQRLoginState {
  final TVQRLoginStatus status;
  final Map<String, dynamic>? qrCodeData;
  final String? qrCodeUrl;
  final int? expiresIn;
  final int? remainingSeconds;
  final String? errorMessage;
  final Map<String, dynamic>? loginResult;

  const TVQRLoginState({
    required this.status,
    this.qrCodeData,
    this.qrCodeUrl,
    this.expiresIn,
    this.remainingSeconds,
    this.errorMessage,
    this.loginResult,
  });

  TVQRLoginState copyWith({
    TVQRLoginStatus? status,
    Map<String, dynamic>? qrCodeData,
    String? qrCodeUrl,
    int? expiresIn,
    int? remainingSeconds,
    String? errorMessage,
    Map<String, dynamic>? loginResult,
  }) {
    return TVQRLoginState(
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      expiresIn: expiresIn ?? this.expiresIn,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
      loginResult: loginResult ?? this.loginResult,
    );
  }

  bool get isLoading => status == TVQRLoginStatus.loading;
  bool get isReady => status == TVQRLoginStatus.qrCodeReady;
  bool get isPolling => status == TVQRLoginStatus.polling;
  bool get isSuccess => status == TVQRLoginStatus.success;
  bool get hasError => status == TVQRLoginStatus.error;
  bool get isExpired => status == TVQRLoginStatus.expired;
  bool get isInitial => status == TVQRLoginStatus.initial;
}

/// TV QR Code Login Controller
class TVQRLoginController extends Notifier<TVQRLoginState> {
  Timer? _pollTimer;
  Timer? _countdownTimer;
  String? _authCode;

  @override
  TVQRLoginState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _countdownTimer?.cancel();
    });

    return const TVQRLoginState(status: TVQRLoginStatus.initial);
  }

  /// Fetch TV QR Code for login
  Future<void> fetchQRCode() async {
    state = state.copyWith(status: TVQRLoginStatus.loading);

    try {
      final fetchTVCode = ref.read(fetchTVCodeUseCaseProvider);
      final result = await fetchTVCode();

      _authCode = result['qrcode_key'] as String?;
      final qrCodeUrl = result['url'] as String?;
      final expiresIn = result['expires_in'] as int?;

      if (_authCode == null || qrCodeUrl == null) {
        state = state.copyWith(
          status: TVQRLoginStatus.error,
          errorMessage: 'Failed to get QR code',
        );
        return;
      }

      state = state.copyWith(
        status: TVQRLoginStatus.qrCodeReady,
        qrCodeData: result,
        qrCodeUrl: qrCodeUrl,
        expiresIn: expiresIn,
        remainingSeconds: expiresIn,
      );

      // Start countdown
      _startCountdown(expiresIn ?? 180);

      // Start polling for login status
      _startPolling();
    } on Failure catch (e) {
      state = state.copyWith(
        status: TVQRLoginStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: TVQRLoginStatus.error,
        errorMessage: 'Unknown error: $e',
      );
    }
  }

  /// Start countdown timer
  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingSeconds ?? seconds;
      if (remaining <= 0) {
        timer.cancel();
        _pollTimer?.cancel();
        state = state.copyWith(
          status: TVQRLoginStatus.expired,
          remainingSeconds: 0,
        );
      } else {
        state = state.copyWith(remainingSeconds: remaining - 1);
      }
    });
  }

  /// Start polling for QR code scan status
  void _startPolling() {
    if (_authCode == null) return;

    state = state.copyWith(status: TVQRLoginStatus.polling);

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_authCode == null) {
        timer.cancel();
        return;
      }

      try {
        final pollQRCode = ref.read(pollQRCodeUseCaseProvider);
        final result = await pollQRCode(
          PollQRCodeParams(authCode: _authCode!),
        );

        if (result.isSuccess) {
          timer.cancel();
          _countdownTimer?.cancel();
          state = state.copyWith(
            status: TVQRLoginStatus.success,
            loginResult: result.data,
          );
        } else if (result.isExpired) {
          timer.cancel();
          _countdownTimer?.cancel();
          state = state.copyWith(
            status: TVQRLoginStatus.expired,
            remainingSeconds: 0,
          );
        }
        // Continue polling for other statuses
      } catch (e) {
        // Log error but continue polling
        print('Polling error: $e');
      }
    });
  }

  /// Reset the controller state
  void reset() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _authCode = null;
    state = const TVQRLoginState(status: TVQRLoginStatus.initial);
  }

  /// Refresh QR code
  Future<void> refresh() async {
    reset();
    await fetchQRCode();
  }
}

/// TV QR Login Controller Provider
final tvqrLoginControllerProvider =
    NotifierProvider<TVQRLoginController, TVQRLoginState>(
      TVQRLoginController.new,
    );
