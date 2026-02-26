# Login Log Feature

Clean Architecture implementation for login history functionality.

## Overview

This feature handles displaying the user's login history. Users can review all past login activities including timestamps, locations, and devices used.

## Architecture

### Domain Layer

**Entities:**
- `LoginLogData` - Contains login history records

**Repository Interface:**
- `LoginLogRepository` - Abstract contract for login log operations

**Use Cases:**
- `GetLoginLogUseCase` - Retrieve login history

### Data Layer

**Data Sources:**
- `LoginLogRemoteDataSource` - Remote API data source

**Models:**
- `LoginLogData` - API response model for login log
- Individual log entry models

**Repositories:**
- `LoginLogRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `LoginLogPageV2` - Main page for displaying login history

**Providers:**
- `LoginLogController` - Controller for managing login log state
- `LoginLogProvider` - Riverpod provider for login log data

## Usage

```dart
import 'package:PiliPlus/features/login_log/login_log.dart';

// Initialize repository and use case
final repository = LoginLogRepositoryImpl(
  remoteDataSource: LoginLogRemoteDataSourceImpl(),
);
final getLoginLog = GetLoginLogUseCase(repository);

// Fetch login history
final result = await getLoginLog();

result.when(
  success: (data) {
    print('Login records: ${data.list?.length ?? 0}');
    for (var log in data.list ?? []) {
      print('Time: ${log.timestamp}');
      print('Location: ${log.location}');
      print('Device: ${log.deviceName}');
      print('IP: ${log.ip}');
      print('Type: ${log.type}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to account security settings
2. User selects "Login History"
3. Presentation layer calls `GetLoginLogUseCase`
4. Use case invokes repository method
5. Repository fetches data from remote API
6. Data is transformed to domain entities
7. Results are displayed with login information

## Log Entry Information

Each login log entry includes:
- `timestamp` - When the login occurred
- `location` - Geographic location (city, country)
- `deviceName` - Device model or name
- `platform` - OS platform (Android, iOS, Web, etc.)
- `ip` - IP address used for login
- `type` - Login type (normal, QR code, token, etc.)
- `status` - Success or failure

## Security Monitoring

Users can use this feature to:
- Monitor account access
- Identify suspicious login attempts
- Track login patterns
- Verify legitimate logins
- Report unauthorized access

## Login Types

Common login types:
- Password - Standard username/password login
- QR Code - Scanned QR code login
- SMS - Verification code login
- Token - Authentication token login
- Third-party - OAuth/social login

## Security Best Practices

Users should:
- Regularly check login history
- Investigate unfamiliar logins
- Change password if suspicious activity found
- Enable two-factor authentication
