/// Entity representing a favorite folder item for selection
class FavFolderItemEntity {
  /// Folder ID
  final int id;

  /// Folder title
  final String title;

  /// Media count in folder
  final int mediaCount;

  /// Folder attributes (visibility, etc.)
  final int attr;

  /// Favorite state: 1 = selected, 0 = not selected
  int favState;

  FavFolderItemEntity({
    required this.id,
    required this.title,
    required this.mediaCount,
    required this.attr,
    this.favState = 0,
  });

  /// Toggle the favorite state
  void toggle() {
    favState = favState == 1 ? 0 : 1;
  }

  /// Check if this folder is currently selected
  bool get isSelected => favState == 1;

  /// Check if this folder is public
  bool get isPublic => (attr & 1) == 0;

  @override
  String toString() =>
      'FavFolderItemEntity(id: $id, title: $title, mediaCount: $mediaCount, favState: $favState)';
}
