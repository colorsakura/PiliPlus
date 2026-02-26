/// Favorite folder entity
class FavFolderEntity {
  final String? mediaId;
  final String title;
  final String? intro;
  final String? cover;
  final int? attr;
  final bool isPublic;

  const FavFolderEntity({
    this.mediaId,
    required this.title,
    this.intro,
    this.cover,
    this.attr,
    this.isPublic = true,
  });

  FavFolderEntity copyWith({
    String? mediaId,
    String? title,
    String? intro,
    String? cover,
    int? attr,
    bool? isPublic,
  }) {
    return FavFolderEntity(
      mediaId: mediaId ?? this.mediaId,
      title: title ?? this.title,
      intro: intro ?? this.intro,
      cover: cover ?? this.cover,
      attr: attr ?? this.attr,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}

/// Favorite folder create/edit parameters
class FavFolderParamsEntity {
  final String title;
  final String? intro;
  final String? cover;
  final bool isPublic;
  final String? mediaId; // null for create, non-null for edit

  const FavFolderParamsEntity({
    required this.title,
    this.intro,
    this.cover,
    this.isPublic = true,
    this.mediaId,
  });

  bool get isAdd => mediaId == null;
}
