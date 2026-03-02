import 'dart:async';

import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/features/login/domain/entities/login_result_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/qr_code_entity.dart';
import 'package:PiliPlus/features/login/domain/entities/sms_code_entity.dart';
import 'package:PiliPlus/features/login/domain/usecases/get_qr_code.dart';
import 'package:PiliPlus/features/login/domain/usecases/login_by_password.dart';
import 'package:PiliPlus/features/login/domain/usecases/login_by_sms.dart';
import 'package:PiliPlus/features/login/domain/usecases/send_sms_code.dart';
import 'package:PiliPlus/features/login/presentation/providers/login_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 登录状态
class LoginState {
  /// 是否正在加载
  final bool isLoading;

  /// 错误消息
  final String? errorMessage;

  /// 二维码信息
  final QrCodeEntity? qrCode;

  /// 二维码剩余时间
  final int qrCodeLeftTime;

  /// 二维码状态消息
  final String qrCodeStatus;

  /// 短信验证码信息
  final SmsCodeEntity? smsCode;

  /// 短信发送冷却时间
  final int smsSendCooldown;

  /// 登录结果
  final LoginResultEntity? loginResult;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.qrCode,
    this.qrCodeLeftTime = 180,
    this.qrCodeStatus = '',
    this.smsCode,
    this.smsSendCooldown = 0,
    this.loginResult,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    QrCodeEntity? qrCode,
    int? qrCodeLeftTime,
    String? qrCodeStatus,
    SmsCodeEntity? smsCode,
    int? smsSendCooldown,
    LoginResultEntity? loginResult,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      qrCode: qrCode ?? this.qrCode,
      qrCodeLeftTime: qrCodeLeftTime ?? this.qrCodeLeftTime,
      qrCodeStatus: qrCodeStatus ?? this.qrCodeStatus,
      smsCode: smsCode ?? this.smsCode,
      smsSendCooldown: smsSendCooldown ?? this.smsSendCooldown,
      loginResult: loginResult ?? this.loginResult,
    );
  }
}

/// 登录Controller
class LoginController extends Notifier<LoginState> {
  late final GetQRCodeUseCase _getQRCodeUseCase;
  late final LoginByPasswordUseCase _loginByPasswordUseCase;
  late final SendSmsCodeUseCase _sendSmsCodeUseCase;
  late final LoginBySmsUseCase _loginBySmsUseCase;

  Timer? _qrCodeTimer;
  Timer? _smsCooldownTimer;
  bool _isPolling = false;

  @override
  LoginState build() {
    _getQRCodeUseCase = ref.read(getQRCodeUseCaseProvider);
    _loginByPasswordUseCase = ref.read(loginByPasswordUseCaseProvider);
    _sendSmsCodeUseCase = ref.read(sendSmsCodeUseCaseProvider);
    _loginBySmsUseCase = ref.read(loginBySmsUseCaseProvider);

    ref.onDispose(() {
      _qrCodeTimer?.cancel();
      _smsCooldownTimer?.cancel();
    });

    return const LoginState();
  }

  /// 获取二维码
  Future<void> fetchQRCode() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final qrCode = await _getQRCodeUseCase();
      state = state.copyWith(
        isLoading: false,
        qrCode: qrCode,
        qrCodeLeftTime: qrCode.expiresIn,
        qrCodeStatus: '',
      );

      // 开始轮询
      _startQrCodePolling(qrCode.authCode);
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }

  /// 开始二维码轮询
  void _startQrCodePolling(String authCode) {
    _qrCodeTimer?.cancel();
    _qrCodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final leftTime = state.qrCodeLeftTime - 1;

      if (leftTime <= 0) {
        timer.cancel();
        state = state.copyWith(
          qrCodeLeftTime: 0,
          qrCodeStatus: '二维码已过期，请刷新',
        );
        return;
      }

      state = state.copyWith(qrCodeLeftTime: leftTime);

      if (!_isPolling) {
        _pollQRCodeStatus(authCode);
      }
    });
  }

  /// 轮询二维码状态
  Future<void> _pollQRCodeStatus(String authCode) async {
    _isPolling = true;

    try {
      // 注意：这里直接使用repository，因为轮询不是usecase的一部分
      final repository = ref.read(loginRepositoryProvider);
      final result = await repository.pollQRCode(authCode);

      if (result['status'] == true) {
        _qrCodeTimer?.cancel();
        state = state.copyWith(
          qrCodeStatus: '扫码成功',
          loginResult: LoginResultEntity.success(
            tokenInfo: TokenInfo.fromMap(result['data']['token_info']),
            cookies: (result['data']['cookie_info']['cookies'] as List)
                .map((e) => CookieInfo.fromMap(e))
                .toList(),
          ),
        );
        // 登录成功，需要保存账号信息
        // 这里应该调用账号保存逻辑
      } else if (result['code'] == 86038) {
        _qrCodeTimer?.cancel();
        state = state.copyWith(qrCodeLeftTime: 0);
      } else {
        state = state.copyWith(qrCodeStatus: result['msg'] as String? ?? '');
      }
    } catch (e) {
      // 忽略轮询错误
    } finally {
      _isPolling = false;
    }
  }

  /// 密码登录
  Future<void> loginWithPassword({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _loginByPasswordUseCase(
        username: username,
        password: password,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          loginResult: result,
        );
        // 登录成功，需要保存账号信息
      } else if (result.needRiskVerify) {
        state = state.copyWith(
          isLoading: false,
          loginResult: result,
          errorMessage: '需要风控验证',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage ?? '登录失败',
        );
      }
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }

  /// 发送短信验证码
  Future<void> sendSmsCode({
    required String tel,
    required Object cid,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final smsCode = await _sendSmsCodeUseCase(
        tel: tel,
        cid: cid,
      );

      state = state.copyWith(
        isLoading: false,
        smsCode: smsCode,
        smsSendCooldown: 60,
      );

      // 开始冷却计时
      _startSmsCooldown();
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }

  /// 开始短信冷却计时
  void _startSmsCooldown() {
    _smsCooldownTimer?.cancel();
    _smsCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final cooldown = state.smsSendCooldown - 1;

      if (cooldown <= 0) {
        timer.cancel();
        state = state.copyWith(smsSendCooldown: 0);
      } else {
        state = state.copyWith(smsSendCooldown: cooldown);
      }
    });
  }

  /// 短信验证码登录
  Future<void> loginWithSms({
    required String tel,
    required String code,
    required Object cid,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final captchaKey = state.smsCode?.captchaKey ?? '';
      if (captchaKey.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '请先获取验证码',
        );
        return;
      }

      final result = await _loginBySmsUseCase(
        tel: tel,
        code: code,
        captchaKey: captchaKey,
        cid: cid,
      );

      state = state.copyWith(
        isLoading: false,
        loginResult: result,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }

  /// 重置状态
  void reset() {
    _qrCodeTimer?.cancel();
    _smsCooldownTimer?.cancel();
    state = const LoginState();
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 登录Controller Provider
final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
