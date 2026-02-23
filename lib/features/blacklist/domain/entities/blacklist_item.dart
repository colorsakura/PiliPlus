import 'package:PiliPlus/models/blacklist/list.dart';
import 'package:PiliPlus/models/model_avatar.dart';

/// 黑名单用户实体
///
/// 封装黑名单用户信息，作为领域层的实体类
class BlacklistItemEntity {
  /// 用户ID
  final int mid;

  /// 属性
  final int? attribute;

  /// 添加时间
  final int mtime;

  /// 标签
  final dynamic tag;

  /// 特殊标记
  final int? special;

  /// 用户名
  final String uname;

  /// 头像URL
  final String face;

  /// 个性签名
  final String? sign;

  /// 头像NFT
  final int? faceNft;

  /// 认证信息
  final BaseOfficialVerify? officialVerify;

  /// VIP信息
  final Vip? vip;

  /// NFT图标
  final String? nftIcon;

  /// 推荐理由
  final String? recReason;

  /// 追踪ID
  final String? trackId;

  /// 关注时间
  final String? followTime;

  const BlacklistItemEntity({
    required this.mid,
    this.attribute,
    required this.mtime,
    this.tag,
    this.special,
    required this.uname,
    required this.face,
    this.sign,
    this.faceNft,
    this.officialVerify,
    this.vip,
    this.nftIcon,
    this.recReason,
    this.trackId,
    this.followTime,
  });

  /// 从模型创建实体
  factory BlacklistItemEntity.fromModel(BlackListItem model) {
    return BlacklistItemEntity(
      mid: model.mid!,
      attribute: model.attribute,
      mtime: model.mtime!,
      tag: model.tag,
      special: model.special,
      uname: model.uname!,
      face: model.face!,
      sign: model.sign,
      faceNft: model.faceNft,
      officialVerify: model.officialVerify,
      vip: model.vip,
      nftIcon: model.nftIcon,
      recReason: model.recReason,
      trackId: model.trackId,
      followTime: model.followTime,
    );
  }

  /// 转换为模型
  BlackListItem toModel() {
    return BlackListItem(
      mid: mid,
      attribute: attribute,
      mtime: mtime,
      tag: tag,
      special: special,
      uname: uname,
      face: face,
      sign: sign,
      faceNft: faceNft,
      officialVerify: officialVerify,
      vip: vip,
      nftIcon: nftIcon,
      recReason: recReason,
      trackId: trackId,
      followTime: followTime,
    );
  }
}
