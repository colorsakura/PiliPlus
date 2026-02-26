import 'package:PiliPlus/features/dlna/domain/repositories/dlna_repository.dart';

/// Stop DLNA search use case
class StopDlnaSearch {
  final DlnaRepository repository;

  const StopDlnaSearch(this.repository);

  Future<void> call() {
    return repository.stopSearch();
  }
}
