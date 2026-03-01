import 'package:PiliPlus/models/model_video.dart';
import 'package:PiliPlus/utils/utils.dart';

part 'model_owner.g.dart';

class Owner implements BaseOwner {
  Owner({
    this.mid,
    this.name,
    this.face,
  });

  @override
  int? mid;
  @override
  String? name;
  String? face;

  Owner.fromJson(Map<String, dynamic> json) {
    mid = Utils.safeToInt(json["mid"]);
    name = json["name"];
    face = json['face'];
  }

  Map<String, dynamic> toJson() => {
    'mid': mid,
    'name': name,
    'face': face,
  };
}
