# Login Devices Feature

Clean Architecture implementation for login devices management functionality.

## Overview

This feature handles displaying and managing all devices where the user account is logged in. Users can view their active login sessions and manage device access.

## Architecture

### Domain Layer

**Entities:**
- `LoginDevicesData` - Contains list of logged-in devices

**Repository Interface:**
- `LoginDevicesRepository` - Abstract contract for login devices operations

**Use Cases:**
- `GetLoginDevicesUseCase` - Retrieve list of logged-in devices

### Data Layer

**Data Sources:**
- `LoginDevicesRemoteDataSource` - Remote API data source

**Models:**
- `LoginDevicesData` - API response model for devices data
- Individual device item models

**Repositories:**
- `LoginDevicesRepositoryImpl` - Concrete implementation using remote data source

### Presentation Layer

**Pages:**
- `LoginDevicesPageV2` - Main page for displaying login devices

**Providers:**
- `LoginDevicesController` - Controller for managing devices state
- `LoginDevicesProvider` - Riverpod provider for devices data

## Usage

```dart
import 'package:PiliPlus/features/login_devices/login_devices.dart';

// Initialize repository and use case
final repository = LoginDevicesRepositoryImpl(
  remoteDataSource: LoginDevicesRemoteDataSourceImpl(),
);
final getLoginDevices = GetLoginDevicesUseCase(repository);

// Fetch login devices
final result = await getLoginDevices();

result.when(
  success: (data) {
    print('Total devices: ${data.list?.length ?? 0}');
    for (var device in data.list ?? []) {
      print('${device.appName} - ${device.deviceName}');
      print('Platform: ${device.platform}');
      print('Login time: ${device.loginTime}');
      print('Current: ${device.isCurrent}');
    }
  },
  error: (error) {
    print('Error: $error');
  },
);
```

## Data Flow

1. User navigates to account security settings
2. User selects "Login Devices"
3. Presentation layer calls `GetLoginDevicesUseCase`
4. Use case invokes repository method
5. Repository fetches data from remote API
6. Data is transformed to domain entities
7. Results are displayed with device information

## Device Information

Each device entry typically includes:
- `appName` - Application name (e.g., "PiliPlus")
- `deviceName` - Device model/name
- `platform` - OS platform (Android, iOS, Web, etc.)
- `loginTime` - When the device logged in
- `isCurrent` - Whether this is the current device
- `deviceId` - Unique device identifier
- `location` - Approximate login location (if available)
- `ip` - IP address (if available)

## Security Features

- View all active login sessions
- Identify current device
- Remote logout capability (in future implementations)
- Security alerts for suspicious logins

## Use Cases

Users typically access this feature to:
- Check for unauthorized access
- Manage active sessions
- Logout from specific devices remotely
- Review login history
