# Adapters Directory

This directory contains adapter functions that convert between Rust-generated models and Flutter models.

## Purpose

The `flutter_rust_bridge` generates Dart models from Rust structs. These adapters provide:

1. **Model Conversion**: Transform Rust-generated models into app-specific models used in `lib/models_new/`
2. **Type Mapping**: Handle special cases like DateTime, enums, and collections
3. **Data Enrichment**: Add computed fields or transform data structures for Flutter UI needs
4. **Compatibility**: Bridge between Rust backend logic and Flutter frontend requirements

## Usage Pattern

```dart
// Convert Rust-generated model to Flutter model
VideoInfo toVideoInfo(RustVideoInfo rust) {
  return VideoInfo(
    bvid: rust.bvid,
    title: rust.title,
    duration: Duration(seconds: rust.durationSeconds),
    // ... more fields
  );
}
```

## Organization

- `video_adapter.dart` - Video-related model conversions
- `user_adapter.dart` - User and account model conversions
- `dynamic_adapter.dart` - Dynamic/feed model conversions
- `*_adapter.dart` - Feature-specific adapters

## Notes

- Keep adapters pure functions (no side effects)
- Validate data at adapter boundaries if needed
- Use extension methods where appropriate for cleaner syntax
