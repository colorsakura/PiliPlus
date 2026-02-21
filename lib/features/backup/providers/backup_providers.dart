// Export all domain providers for convenience
export 'domain_providers.dart';

import 'package:PiliPlus/features/backup/presentation/providers/backup_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============ Controller Provider ============
final backupControllerProvider =
    NotifierProvider<BackupController, BackupState>(BackupController.new);
