import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/backup/providers/backup_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({
    super.key,
    this.showAppBar = true,
  });

  final bool showAppBar;

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  late final TextEditingController _uriCtr;
  late final TextEditingController _usernameCtr;
  late final TextEditingController _passwordCtr;
  late final TextEditingController _directoryCtr;

  @override
  void initState() {
    super.initState();
    final state = ref.read(backupControllerProvider);
    final config = state.config;
    _uriCtr = TextEditingController(text: config.uri);
    _usernameCtr = TextEditingController(text: config.username);
    _passwordCtr = TextEditingController(text: config.password);
    _directoryCtr = TextEditingController(text: config.directory);
  }

  @override
  void dispose() {
    _uriCtr.dispose();
    _usernameCtr.dispose();
    _passwordCtr.dispose();
    _directoryCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    final state = ref.watch(backupControllerProvider);
    final controller = ref.read(backupControllerProvider.notifier);

    // 显示错误提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            duration: const Duration(seconds: 2),
          ),
        );
        controller.clearError();
      }
    });

    final isLoading = state.isLoading;
    final obscureText = state.obscureText;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text('WebDAV 设置'))
          : null,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ListView(
            padding: padding.copyWith(
              top: 20,
              left: 20 + (widget.showAppBar ? padding.left : 0),
              right: 20 + (widget.showAppBar ? padding.right : 0),
              bottom: padding.bottom + 100,
            ),
            children: [
              TextField(
                controller: _uriCtr,
                decoration: const InputDecoration(
                  labelText: '地址',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameCtr,
                decoration: const InputDecoration(
                  labelText: '用户',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordCtr,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  labelText: '密码',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: obscureText,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _directoryCtr,
                decoration: const InputDecoration(
                  labelText: '路径',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: StyleString.mdRadius,
                        ),
                      ),
                      onPressed: isLoading ? null : _backup,
                      child: const Text('备份设置'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: StyleString.mdRadius,
                        ),
                      ),
                      onPressed: isLoading ? null : _restore,
                      child: const Text('恢复设置'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: kFloatingActionButtonMargin +
                (widget.showAppBar ? padding.right : 0),
            bottom: kFloatingActionButtonMargin + padding.bottom,
            child: FloatingActionButton(
              onPressed: isLoading ? null : _saveConfig,
              child: const Icon(Icons.save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConfig() async {
    final controller = ref.read(backupControllerProvider.notifier);
    // 更新配置值
    controller
      ..updateUri(_uriCtr.text)
      ..updateUsername(_usernameCtr.text)
      ..updatePassword(_passwordCtr.text)
      ..updateDirectory(_directoryCtr.text);

    final success = await controller.saveConfig();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '配置成功' : '配置失败'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _backup() async {
    final controller = ref.read(backupControllerProvider.notifier);
    await controller.backup();

    if (!mounted) return;
    final state = ref.read(backupControllerProvider);
    if (state.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('备份成功'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _restore() async {
    final controller = ref.read(backupControllerProvider.notifier);
    await controller.restore();

    if (!mounted) return;
    final state = ref.read(backupControllerProvider);
    if (state.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('恢复成功'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
