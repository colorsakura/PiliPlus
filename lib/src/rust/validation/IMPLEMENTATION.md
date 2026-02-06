# Video API Validator Implementation

## Overview

The A/B comparison validator has been successfully implemented in:
`lib/src/rust/validation/video_validator.dart`

## Implementation Details

### VideoApiValidator Class

The validator provides the following key features:

#### 1. Main Validation Method
```dart
static Future<ValidationResult> validateGetVideoInfo(String bvid)
```
- Calls both Rust and Flutter implementations in parallel
- Compares results field-by-field
- Returns detailed ValidationResult

#### 2. Comparison Logic
```dart
static ValidationResult compareResults(
  String bvid,
  VideoDetailResponse? rustResult,
  VideoDetailResponse? flutterResult,
)
```
- Handles edge cases (both failed, asymmetric failures)
- Compares key fields from VideoDetailData
- Logs all mismatches with detailed context

#### 3. Field Comparison
Compares the following fields:
- **Video IDs:** bvid, aid
- **Metadata:** title, desc, duration
- **Owner Info:** owner.name, owner.mid
- **Statistics:** stat.view, stat.like, stat.coin, stat.favorite, stat.share
- **Structure:** cid, pages.length

#### 4. Implementation Callers
- `_callRustImplementation()` - Calls Rust API directly via FFI
- `_callFlutterImplementation()` - Calls via VideoHttp facade

### ValidationResult Class

Encapsulates validation outcomes:
```dart
class ValidationResult {
  final bool passed;
  final String? message;

  ValidationResult.passed(this.message)
  ValidationResult.failed(this.message)
  ValidationResult.skipped(this.message)
  ValidationResult.error(this.message)
}
```

## Key Features

### 1. Parallel Execution
Both implementations are called simultaneously using `Future.wait()` for efficiency:
```dart
final results = await Future.wait([
  _callRustImplementation(bvid),
  _callFlutterImplementation(bvid),
]);
```

### 2. Comprehensive Logging
All operations are logged with emoji indicators:
- ✅ Passed validation
- ❌ Failed validation/mismatch
- ⚠️  Warnings (both implementations failed)

Example log output:
```
✅ Validation passed for BV1xx411c7mD
```
or
```
❌ Mismatch for BV1xx411c7mD.title
  Rust:    "Video Title 1"
  Flutter: "Video Title 2"
```

### 3. Edge Case Handling
- Both implementations failing → Consistent behavior (pass)
- One failing, one succeeding → Inconsistent (fail)
- Null data handling → Graceful comparison

### 4. Error Handling
- Network errors caught and logged
- JSON parsing errors caught
- Returns ValidationResult.error with details

## Usage Examples

### Basic Validation
```dart
final result = await VideoApiValidator.validateGetVideoInfo('BV1xx411c7mD');
if (result.passed) {
  print('✅ ${result.message}');
} else {
  print('❌ ${result.message}');
}
```

### Batch Validation
```dart
final testBvids = ['BV1xx411c7mD', 'BV1yy411c7mE', 'BV1zz411c7mF'];

for (final bvid in testBvids) {
  final result = await VideoApiValidator.validateGetVideoInfo(bvid);
  print('$bvid: $result');
}
```

## File Structure

```
lib/src/rust/validation/
├── README.md                 (existing - overview)
├── video_validator.dart      (NEW - main implementation)
└── example_usage.dart        (NEW - usage documentation)
```

## Integration Points

### With VideoApiFacade
The validator works independently of the facade:
- Does not rely on `Pref.useRustVideoApi` flag
- Calls both implementations directly
- Ensures accurate A/B comparison

### With VideoHttp
Uses existing VideoHttp.videoIntro() method for Flutter implementation

### With Rust API
Uses rust.getVideoInfo() directly via FFI bridge

## Performance Considerations

1. **Network Calls:** Makes 2x API calls (one per implementation)
2. **Parallel Execution:** Reduces total time by running calls concurrently
3. **Memory:** Minimal overhead, only stores comparison results

## Testing Status

✅ Code compiles without errors
✅ No analysis warnings
✅ Ready for integration testing (Task 55)
✅ Ready for performance measurement (Task 56)

## Next Steps

- **Task 54:** Add validation enable flag to settings
- **Task 55:** Test with real video IDs
- **Task 56:** Add performance metrics collection
- **Task 57:** Document findings and issues

## Technical Notes

### Flag Handling
The validator bypasses the `useRustVideoApi` flag and calls implementations
directly to ensure accurate comparison regardless of user settings.

### Data Conversion
Uses VideoAdapter.fromRust() to convert Rust VideoInfo to Flutter VideoDetailData

### Future Enhancements
Possible improvements:
- Batch validation API
- Performance metrics collection
- Statistical analysis of mismatches
- CI/CD integration
