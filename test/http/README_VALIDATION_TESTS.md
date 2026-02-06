# Video API Validation Tests

This directory contains integration tests to validate that the Rust and Flutter implementations of the video API produce identical results.

## Overview

The validation tests perform A/B comparisons between:
- **Rust implementation**: `lib/src/rust/api/video.dart`
- **Flutter implementation**: `lib/http/video.dart`

They validate that both implementations return identical data when fetching the same video from Bilibili's API.

## Test Files

### Unit Tests
- **`video_api_validation_test.dart`**: Unit tests that can run without full app initialization
  - Tests the validator logic
  - Mocks network responses where needed
  - Fast execution, good for CI/CD

### Integration Tests
- **`integration_test/video_api_validation_integration_test.dart`**: Full integration tests
  - Requires Rust library initialization
  - Makes real API calls to Bilibili
  - Tests with real video IDs
  - Slower but more comprehensive

## Running the Tests

### Unit Tests

```bash
# Run all validation tests
flutter test test/http/video_api_validation_test.dart

# Run specific test group
flutter test test/http/video_api_validation_test.dart --name "popular"

# Run with verbose output
flutter test test/http/video_api_validation_test.dart --no-sound-null-safety -r expanded
```

### Integration Tests

```bash
# Run all integration tests
flutter test integration_test/video_api_validation_integration_test.dart

# Run on specific device
flutter test integration_test/video_api_validation_integration_test.dart -d <device_id>

# Run with verbose output
flutter test integration_test/video_api_validation_integration_test.dart -r expanded
```

## Test Coverage

### Video Categories Tested

1. **Popular Videos**: High-view count videos from various categories
2. **Different Video Types**:
   - Technology & Programming tutorials
   - Gaming content
   - Music covers and originals
   - Entertainment & Vlogs
   - Educational content
   - Animation & Anime

3. **Edge Cases**:
   - Very short videos (< 5 minutes)
   - Very long videos (> 20 minutes)
   - Multi-part videos (multiple pages)
   - High engagement videos (many likes/views)

4. **Error Handling**:
   - Invalid video IDs
   - Network errors
   - Missing videos

### Fields Validated

The validator compares the following fields between Rust and Flutter implementations:

- **Video IDs**: `bvid`, `aid`
- **Metadata**: `title`, `desc` (description), `duration`
- **Owner**: `owner.mid`, `owner.name`, `owner.face`
- **Statistics**: `stat.view`, `stat.like`, `stat.coin`, `stat.favorite`, `stat.share`
- **Pages**: `pages.length`, individual page data
- **CID**: `cid` (content ID)

## Understanding Test Results

### Success Indicators

```
✅ PASS: All fields match
```

Both implementations returned identical data.

### Failure Indicators

```
❌ FAIL: Found N mismatches:
  bvid: Rust="BV1xxx" vs Flutter="BV1yyy"
  title: Rust="Video 1" vs Flutter="Video 2"
```

This indicates:
- Possible field mapping issues in `VideoAdapter`
- Type conversion problems
- Differences in API response handling

### Error Indicators

```
⚠️  ERROR: Network error - ...
⚠️  ERROR: HTTP error - ...
```

This indicates:
- Network connectivity issues
- Invalid video IDs (deleted/private videos)
- API rate limiting
- Server-side errors

## Sample Output

```
=== Testing 19 popular Bilibili videos ===

Testing: BV1GJ411x7h7
  ✅ PASS (523ms): All fields match
Testing: BV1uv411q7Mv
  ✅ PASS (487ms): All fields match
Testing: BV1vA411b7Fq
  ❌ FAIL (512ms): Found 2 mismatches:
    stat.view: Rust=1000000 vs Flutter=1000001
    stat.like: Rust=50000 vs Flutter=50001

============================================================
VALIDATION TEST SUMMARY
============================================================
Total videos tested: 19
✅ Passed:  17 (89.5%)
❌ Failed:  2 (10.5%)
⚠️  Errors:  0 (0.0%)
============================================================
```

## Troubleshooting

### "Rust library not initialized" Error

**Problem**: Tests fail with `Bad state: flutter_rust_bridge has not been initialized`

**Solution**: Use integration tests instead of unit tests:
```bash
flutter test integration_test/video_api_validation_integration_test.dart
```

### Network Errors

**Problem**: Tests fail with network errors

**Possible Causes**:
- No internet connection
- Bilibili API is down
- Firewall blocking requests

**Solution**: Check network connectivity and try again later.

### Video ID Errors

**Problem**: Many tests fail with "video not found"

**Possible Causes**:
- Video IDs are outdated (videos deleted or made private)
- Region restrictions

**Solution**: Update test video IDs with current valid IDs from Bilibili.

### High Failure Rate

**Problem**: More than 30% of tests show mismatches

**Possible Causes**:
- `VideoAdapter` field mapping issues
- Type conversion bugs
- API response format changes

**Solution**:
1. Review failed test details
2. Check `lib/src/rust/adapters/video_adapter.dart`
3. Verify field mappings
4. Update adapter as needed

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# .github/workflows/test.yml
- name: Run validation tests
  run: flutter test integration_test/video_api_validation_integration_test.dart

- name: Check test results
  run: |
    # Fail if more than 30% of tests have mismatches
    python scripts/check_validation_results.py
```

## Adding New Test Cases

To add more test videos:

1. Find valid Bilibili video IDs
2. Add them to the appropriate test list in `video_api_validation_integration_test.dart`:

```dart
final testVideos = [
  'BV1xxxxxxxxxx', // Your new video ID
  // ... existing IDs
];
```

3. Run the tests to validate

## Performance Considerations

- Tests run sequentially to avoid API rate limiting
- 500ms delay between requests
- Total test time: ~10-15 seconds per video
- Use `--timeout` flag for large test suites:

```bash
flutter test integration_test/video_api_validation_integration_test.dart --timeout 15m
```

## Related Files

- **Validator**: `lib/src/rust/validation/video_validator.dart`
- **Adapter**: `lib/src/rust/adapters/video_adapter.dart`
- **Rust API**: `lib/src/rust/api/video.dart`
- **Flutter API**: `lib/http/video.dart`
- **Facade**: `lib/http/video_api_facade.dart`

## Support

For issues or questions:
1. Check test output for specific error messages
2. Review failed field mappings
3. Verify Rust library is properly compiled
4. Check network connectivity
5. Ensure video IDs are still valid
