# Download Feature

Offline cache management for videos and content with download tracking.

## Architecture

### Domain Layer
- **Entities**: `FetchDownloadListParams`, `CancelDownloadParams`, `PauseDownloadParams`, `ResumeDownloadParams`, `DeleteDownloadParams`
- **Repository**: `DownloadRepository`
- **Use Cases**: `FetchDownloadList`, `CancelDownload`, `PauseDownload`, `ResumeDownload`, `DeleteDownload`, `DeleteDownloadPage`

### Data Layer
- **Service Data Source**: `DownloadServiceDataSource` / `DownloadServiceDataSourceImpl`
- **Repository Implementation**: `DownloadRepositoryImpl`
- **Service**: Wraps `DownloadService` (system service)

### Presentation Layer
- **Pages**: `DownloadPage`
- **Controllers**: `DownloadPageController`, `DownloadMultiSelectController`, `DownloadPageDataController`

## Key Features

- **Download Management**: Start, pause, resume, cancel downloads
- **Multi-Select**: Batch operations on multiple downloads
- **Progress Tracking**: Real-time download progress updates
- **Storage Management**: Delete downloads to free space
- **Grouped Display**: Downloads organized by type and date

## Usage

```dart
// Fetch download list
final fetchDownloadList = FetchDownloadList(repository);
final result = await fetchDownloadList(FetchDownloadListParams());

// Cancel download
final cancelDownload = CancelDownload(repository);
await cancelDownload(CancelDownloadParams(
  isDelete: false,
  downloadNext: true,
));

// Pause download
await pauseDownload.call(PauseDownloadParams());

// Resume download
await resumeDownload.call(ResumeDownloadParams(entry: entry));

// Delete download
await deleteDownload.call(DeleteDownloadParams(
  entry: entry,
  removeList: true,
));

// Delete page
await deleteDownloadPage.call(pageDirPath);
```

## Architecture Notes

This feature demonstrates a **service-based architecture pattern**:

- **Service Layer**: `DownloadService` is a system-level service managing downloads
- **Data Source**: `DownloadServiceDataSourceImpl` wraps the service
- **Repository**: Provides business operations on downloads
- **Use Cases**: Encapsulate specific operations (pause, resume, cancel, etc.)

The Clean Architecture layers here adapt to the system service pattern:
- Domain layer defines download business operations
- Data layer wraps the existing service
- Presentation layer manages UI and user interactions

This approach maintains Clean Architecture principles while working with existing system services.
