import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/features/auth/domain/entities/auth_params.dart';
import 'package:PiliPlus/features/auth/presentation/providers/auth_controller.dart';
import 'package:PiliPlus/features/auth/presentation/providers/auth_providers.dart';

void main() {
  group('TVQRLoginState', () {
    test('should have correct initial state', () {
      // Arrange & Act
      const state = TVQRLoginState(status: TVQRLoginStatus.initial);

      // Assert
      expect(state.status, equals(TVQRLoginStatus.initial));
      expect(state.isInitial, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
    });

    test('should identify loading state correctly', () {
      // Arrange & Act
      const state = TVQRLoginState(status: TVQRLoginStatus.loading);

      // Assert
      expect(state.isLoading, isTrue);
      expect(state.isInitial, isFalse);
    });

    test('should identify ready state correctly', () {
      // Arrange & Act
      const state = TVQRLoginState(
        status: TVQRLoginStatus.qrCodeReady,
        qrCodeUrl: 'https://example.com/qr',
        remainingSeconds: 180,
      );

      // Assert
      expect(state.isReady, isTrue);
      expect(state.qrCodeUrl, equals('https://example.com/qr'));
      expect(state.remainingSeconds, equals(180));
    });

    test('should identify polling state correctly', () {
      // Arrange & Act
      const state = TVQRLoginState(status: TVQRLoginStatus.polling);

      // Assert
      expect(state.isPolling, isTrue);
    });

    test('should identify success state correctly', () {
      // Arrange & Act
      const state = TVQRLoginState(
        status: TVQRLoginStatus.success,
        loginResult: {'token': 'test'},
      );

      // Assert
      expect(state.isSuccess, isTrue);
      expect(state.loginResult?.isNotEmpty, isTrue);
    });

    test('should identify error state correctly', () {
      // Arrange & Act
      const state = TVQRLoginState(
        status: TVQRLoginStatus.error,
        errorMessage: 'Test error',
      );

      // Assert
      expect(state.hasError, isTrue);
      expect(state.errorMessage, equals('Test error'));
    });

    test('should identify expired state correctly', () {
      // Arrange & Act
      const state = TVQRLoginState(status: TVQRLoginStatus.expired);

      // Assert
      expect(state.isExpired, isTrue);
    });

    test('should copy with new values correctly', () {
      // Arrange
      const state1 = TVQRLoginState(status: TVQRLoginStatus.initial);

      // Act
      final state2 = state1.copyWith(
        status: TVQRLoginStatus.loading,
        errorMessage: 'Error',
      );

      // Assert
      expect(state1.status, equals(TVQRLoginStatus.initial));
      expect(state2.status, equals(TVQRLoginStatus.loading));
      expect(state2.errorMessage, equals('Error'));
    });
  });

  group('QRCodePollResult', () {
    test('should identify expired status correctly', () {
      // Arrange & Act
      const result = QRCodePollResult(
        isSuccess: false,
        code: 86038,
        message: '二维码已过期',
      );

      // Assert
      expect(result.isExpired, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('should identify scanned status correctly', () {
      // Arrange & Act
      const result = QRCodePollResult(
        isSuccess: false,
        code: 86090,
        message: '已扫码',
      );

      // Assert
      expect(result.isScanned, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('should identify success status correctly', () {
      // Arrange & Act
      const result = QRCodePollResult(
        isSuccess: true,
        code: 0,
        data: {'token': 'test'},
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.isExpired, isFalse);
      expect(result.isScanned, isFalse);
    });
  });

  group('Auth Params', () {
    test('FetchTVCodeParams should have default values', () {
      // Arrange & Act
      const params = FetchTVCodeParams();

      // Assert
      expect(params.localId, equals('0'));
      expect(params.platform, equals('android'));
      expect(params.mobiApp, equals('android_hd'));
    });

    test('PollQRCodeParams should require authCode', () {
      // Arrange & Act
      const params = PollQRCodeParams(authCode: 'test_code');

      // Assert
      expect(params.authCode, equals('test_code'));
      expect(params.localId, equals('0'));
    });
  });
}
