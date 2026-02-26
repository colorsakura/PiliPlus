# Validate Feature

Clean Architecture implementation for validation/captcha functionality.

## Overview

This feature handles Gaia verification/captcha operations for security validation on the platform.

## Architecture

### Domain Layer

**Repository Interface:**
- `ValidateRepository` - Abstract contract for validation operations

**Use Cases:**
- `GaiaVgateRegister` - Register for Gaia verification code
- `GaiaVgateValidate` - Validate Gaia verification code

### Data Layer

**Data Sources:**
- `ValidateRemoteDataSource` - HTTP client for validation API endpoints

**Repositories:**
- `ValidateRepositoryImpl` - Concrete implementation with error handling

## Usage

```dart
import 'package:PiliPlus/features/validate/validate.dart';

// Initialize repository and use cases
final repository = ValidateRepositoryImpl(
  remoteDataSource: ValidateRemoteDataSource(),
);

final register = GaiaVgateRegister(repository);
final validate = GaiaVgateValidate(repository);

// Register for Gaia verification
final regResult = await register('v_voucher_token');

if (regResult case Success(:final data)) {
  print('Registration data: $data');
}

// Validate Gaia verification code
final valResult = await validate(
  challenge: 'challenge_value',
  seccode: 'seccode_value',
  token: 'token_value',
  validate: 'validate_value',
);

if (valResult case Success(:final data)) {
  print('Validation successful: $data');
}
```

## API Operations

The `ValidateRemoteDataSource` provides:

| Method | Description |
|--------|-------------|
| `gaiaVgateRegister` | Register for Gaia verification code with voucher |
| `gaiaVgateValidate` | Validate Gaia verification code with challenge response |

## Gaia Verification Flow

1. **Register** - Call `gaiaVgateRegister` with a voucher token to initiate verification
2. **Display Captcha** - Show the captcha challenge to the user
3. **Validate** - Call `gaiaVgateValidate` with the user's response

## Error Handling

The repository catches `ServerException` and general `Exception`, converting them to `LoadingState` for consistent error handling in the presentation layer.

Common error messages:
- 'Gaia 验证码注册失败' - Failed to register verification code
- 'Gaia 验证码验证失败' - Failed to validate verification code
