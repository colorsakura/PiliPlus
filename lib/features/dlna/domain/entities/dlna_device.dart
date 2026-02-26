/// DLNA device entity
class DlnaDeviceEntity {
  final String id;
  final String name;
  final String location;
  final bool isConnected;

  const DlnaDeviceEntity({
    required this.id,
    required this.name,
    required this.location,
    this.isConnected = false,
  });

  DlnaDeviceEntity copyWith({
    String? id,
    String? name,
    String? location,
    bool? isConnected,
  }) {
    return DlnaDeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

/// DLNA search result entity
class DlnaSearchResultEntity {
  final List<DlnaDeviceEntity> devices;
  final bool isSearching;
  final String? error;

  const DlnaSearchResultEntity({
    this.devices = const [],
    this.isSearching = false,
    this.error,
  });
}
