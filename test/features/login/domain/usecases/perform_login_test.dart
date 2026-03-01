import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/login_result_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/qr_code_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/risk_verify_info_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/sms_code_entity.dart';
import 'package:PiliPlus/features/login/domain/repositories/login_repository.dart';
import 'package:PiliPlus/features/login/domain/usecases/perform_login.dart';
import 'package:PiliPlus/models/login/model.dart';

/// 手动 Mock LoginRepository（避免添加 mockito 依赖）
class MockLoginRepository implements LoginRepository {
  LoginEntity? loginResult;
  Object? errorToThrow;
  int performLoginCallCount = 0;
  String? lastUsername;
  String? lastPassword;

  @override
  Future<LoginEntity> performLogin({
    required String username,
    required String password,
  }) async {
    performLoginCallCount++;
    lastUsername = username;
    lastPassword = password;

    if (errorToThrow != null) {
      throw errorToThrow as Object;
    }

    if (loginResult != null) {
      return loginResult!;
    }

    throw UnimplementedError('loginResult not set');
  }

  @override
  Future<LoginEntity> refreshToken(String refreshToken) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<QrCodeEntity> getQRCode() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> pollQRCode(String authCode) {
    throw UnimplementedError();
  }

  @override
  Future<LoginResultEntity> loginByPassword({
    required String username,
    required String password,
    required String key,
    required String salt,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SmsCodeEntity> sendSmsCode({
    required Object cid,
    required String tel,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoginResultEntity> loginBySms({
    required String tel,
    required String code,
    required String captchaKey,
    required Object cid,
    required String key,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getWebKey() {
    throw UnimplementedError();
  }

  @override
  Future<RiskVerifyInfoEntity> getRiskVerifyInfo({
    required String tmpCode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SmsCodeEntity> sendRiskVerifySms({
    required String tmpCode,
    String? geeChallenge,
    String? geeSeccode,
    String? geeValidate,
    String? recaptchaToken,
    required String refererUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<String> submitRiskVerifySms({
    required String code,
    required String tmpCode,
    required String requestId,
    required String source,
    required String captchaKey,
    required String refererUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<LoginResultEntity> oauth2AccessToken({
    required String code,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> preCapture() {
    throw UnimplementedError();
  }

  @override
  Future<CaptchaDataModel> queryCaptcha() {
    throw UnimplementedError();
  }

  void reset() {
    loginResult = null;
    errorToThrow = null;
    performLoginCallCount = 0;
    lastUsername = null;
    lastPassword = null;
  }
}

void main() {
  late PerformLoginUseCase useCase;
  late MockLoginRepository mockRepository;

  setUp(() {
    mockRepository = MockLoginRepository();
    useCase = PerformLoginUseCase(mockRepository);
  });

  tearDown(() {
    mockRepository.reset();
  });

  group('PerformLoginUseCase', () {
    const tUsername = 'test@example.com';
    const tPassword = 'password123';
    const tLoginEntity = LoginEntity(
      userId: '12345',
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
      expiresIn: 1234567890,
    );

    test('should login successfully with valid credentials', () async {
      // arrange
      mockRepository.loginResult = tLoginEntity;

      // act
      final result = await useCase.call(
        username: tUsername,
        password: tPassword,
      );

      // assert
      expect(result, equals(tLoginEntity));
      expect(mockRepository.performLoginCallCount, equals(1));
      expect(mockRepository.lastUsername, equals(tUsername));
      expect(mockRepository.lastPassword, equals(tPassword));
    });

    test('should throw ValidationFailure when username is empty', () async {
      // act
      final call = useCase.call(username: '', password: tPassword);

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      expect(mockRepository.performLoginCallCount, equals(0));
    });

    test('should throw ValidationFailure when password is empty', () async {
      // act
      final call = useCase.call(username: tUsername, password: '');

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      expect(mockRepository.performLoginCallCount, equals(0));
    });

    test('should throw ValidationFailure when password is too short', () async {
      // act
      final call = useCase.call(username: tUsername, password: '12345');

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      expect(mockRepository.performLoginCallCount, equals(0));
    });

    test('should throw ValidationFailure when username contains only whitespace', () async {
      // act
      final call = useCase.call(username: '   ', password: tPassword);

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      expect(mockRepository.performLoginCallCount, equals(0));
    });

    test('should throw ValidationFailure when password contains only whitespace', () async {
      // act
      final call = useCase.call(username: tUsername, password: '   ');

      // assert
      expect(() => call, throwsA(isA<ValidationFailure>()));
      expect(mockRepository.performLoginCallCount, equals(0));
    });
  });
}
