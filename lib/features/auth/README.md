# Authentication Feature

Handles user authentication operations including TV QR code login, password login, and SMS verification.

## Architecture

### Domain Layer
- **Entities**: `FetchTVCodeParams`, `PollQRCodeParams`, `QRCodePollResult`
- **Repository**: `AuthRepository`
- **Use Cases**: `FetchTVCode`, `PollQRCode`, `QueryCaptcha`

### Data Layer
- **Remote DataSource**: `AuthRemoteDataSource` (base class with HTTP implementation)
- **Repository Implementation**: `AuthRepositoryImpl`

### Key Features

- **TV QR Code Login**: Scan QR code with Bilibili TV app
- **Password Login**: RSA-encrypted password authentication
- **SMS Verification**: Send and verify SMS codes
- **Captcha Support**: Handle captcha challenges

## Usage

```dart
// Fetch TV QR code
final fetchTVCode = FetchTVCode(repository);
final qrData = await fetchTVCode();
// Display qrData['qrcode_key'] as QR code

// Poll for login status
final pollQRCode = PollQRCode(repository);
final result = await pollQRCode(PollQRCodeParams(authCode: 'xxx'));
if (result.isSuccess) {
  // Login successful, handle result.data
}
```

## Implementation Notes

The data source is implemented as a base class (`AuthRemoteDataSource`) with all HTTP logic, and the implementation class extends it to satisfy the interface. This preserves the existing implementation while adding Clean Architecture structure.
