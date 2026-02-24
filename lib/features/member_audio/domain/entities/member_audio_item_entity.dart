import 'package:PiliPlus/models/space/space_audio/item.dart';

/// Entity for member audio items
///
/// This is a simple wrapper around the existing SpaceAudioItem model.
/// In a full migration, this would be a pure domain object without
/// dependencies on data layer models.
typedef MemberAudioItemEntity = SpaceAudioItem;
