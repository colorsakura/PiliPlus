/// Share user entity
class ShareUserEntity {
  final int mid;
  final String name;
  final String avatar;
  bool selected;

  ShareUserEntity({
    required this.mid,
    required this.name,
    required this.avatar,
    this.selected = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is ShareUserEntity) {
      return mid == other.mid;
    }
    return false;
  }

  @override
  int get hashCode => mid.hashCode;

  /// Copy with method for immutability
  ShareUserEntity copyWith({
    int? mid,
    String? name,
    String? avatar,
    bool? selected,
  }) {
    return ShareUserEntity(
      mid: mid ?? this.mid,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      selected: selected ?? this.selected,
    );
  }
}

// Backward compatibility alias
typedef UserModel = ShareUserEntity;
