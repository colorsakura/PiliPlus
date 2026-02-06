# Validation Directory

This directory contains A/B testing and validation logic for Rust-bridged functionality.

## Purpose

Since PiliPlus is a third-party client, we need careful validation before using Rust-bridged features:

1. **Feature Flags**: Control which Rust features are enabled
2. **A/B Testing**: Validate experimental features against production APIs
3. **Compatibility Checks**: Ensure Rust implementations match existing behavior
4. **Fallback Logic**: Switch to HTTP APIs if Rust implementation fails

## Usage Pattern

```dart
// Check if Rust implementation is safe to use
Future<bool> canUseRustVideoApi() async {
  // Check feature flag
  if (!Settings.enableRustBackend) return false;

  // Run A/B test comparison
  final rustResult = await RustApi.getVideoInfo(bvid);
  final httpResult = await HttpApi.getVideoInfo(bvid);

  // Validate results match
  return validateVideoInfoMatch(rustResult, httpResult);
}
```

## Organization

- `feature_flags.dart` - Feature flag management
- `ab_test_validator.dart` - A/B test comparison logic
- `video_validator.dart` - Video API validation
- `*_validator.dart` - Feature-specific validation

## Strategy

1. **Phase 1**: Implement validators that compare Rust vs HTTP results
2. **Phase 2**: Enable Rust features for beta testers with monitoring
3. **Phase 3**: Gradual rollout based on validation results
4. **Phase 4**: Full replacement after validation confidence is high

## Safety

- Always provide HTTP fallback
- Log discrepancies for debugging
- Never break existing functionality
- Allow users to opt-out via settings
