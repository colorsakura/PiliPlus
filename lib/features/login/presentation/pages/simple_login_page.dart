import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/login/presentation/providers/simple_login_controller.dart';

/// 简化的登录页面（用于演示干净架构）
class SimpleLoginPage extends ConsumerStatefulWidget {
  const SimpleLoginPage({super.key});

  @override
  ConsumerState<SimpleLoginPage> createState() => _SimpleLoginPageState();
}

class _SimpleLoginPageState extends ConsumerState<SimpleLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(simpleLoginControllerProvider.notifier)
          .login(
            username: _usernameController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(simpleLoginControllerProvider);

    // 监听登录成功
    ref.listen<SimpleLoginState>(
      simpleLoginControllerProvider,
      (previous, next) {
        if (next.isSuccess) {
          // 显示成功消息
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录成功！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('登录（干净架构演示）')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person, size: 100),
                const SizedBox(height: 48),

                // 用户名输入框
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名/邮箱',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                  enabled: !loginState.isLoading,
                ),

                const SizedBox(height: 16),

                // 密码输入框
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码长度不能少于6位';
                    }
                    return null;
                  },
                  enabled: !loginState.isLoading,
                ),

                const SizedBox(height: 24),

                // 错误提示
                if (loginState.hasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loginState.errorMessage ?? '登录失败',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (loginState.hasError) const SizedBox(height: 16),

                // 登录按钮
                ElevatedButton(
                  onPressed: loginState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loginState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登录', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),

                // 重置按钮
                OutlinedButton(
                  onPressed: loginState.isLoading
                      ? null
                      : () {
                          ref
                              .read(simpleLoginControllerProvider.notifier)
                              .reset();
                          _formKey.currentState?.reset();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('重置', style: TextStyle(fontSize: 16)),
                ),

                // 成功信息
                if (loginState.isSuccess)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '登录成功！',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                          ],
                        ),
                        if (loginState.loginEntity != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '用户ID: ${loginState.loginEntity!.userId}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '令牌过期时间: ${DateTime.fromMillisecondsSinceEpoch(loginState.loginEntity!.expiresIn * 1000).toLocal()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
