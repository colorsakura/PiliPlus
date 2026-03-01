import 'package:PiliPlus/utils/extension/map_ext.dart';

class UserInfoData {
  UserInfoData({
    this.isLogin,
    this.emailVerified,
    this.face,
    this.levelInfo,
    this.mid,
    this.mobileVerified,
    this.money,
    this.moral,
    this.official,
    this.officialVerify,
    this.pendant,
    this.scores,
    this.uname,
    this.vipDueDate,
    this.vipStatus,
    this.vipType,
    this.vipPayType,
    this.vipThemeType,
    this.vipLabel,
    this.vipAvatarSub,
    this.vipNicknameColor,
    this.wallet,
    this.hasShop,
    this.shopUrl,
    this.isSeniorMember,
  });

  bool? isLogin;
  int? emailVerified;
  String? face;
  LevelInfo? levelInfo;
  int? mid;
  int? mobileVerified;
  double? money;
  int? moral;
  Map? official;
  Map? officialVerify;
  Map? pendant;
  int? scores;
  String? uname;
  int? vipDueDate;
  int? vipStatus;
  int? vipType;
  int? vipPayType;
  int? vipThemeType;
  Map? vipLabel;
  int? vipAvatarSub;
  String? vipNicknameColor;
  Map? wallet;
  bool? hasShop;
  String? shopUrl;
  int? isSeniorMember;

  UserInfoData.fromJson(Map<String, dynamic> json) {
    isLogin = json['isLogin'] ?? false;
    emailVerified = json['email_verified'];
    face = json['face'];
    levelInfo = json['level_info'] != null
        ? LevelInfo.fromJson(json['level_info'])
        : null;
    mid = json['mid'];
    mobileVerified = json['mobile_verified'];
    money = json['money'] is int ? json['money'].toDouble() : json['money'];
    moral = json['moral'];
    official = json['official'];
    officialVerify = json['officialVerify'];
    pendant = json['pendant'];
    scores = json['scores'];
    uname = json['uname'];
    vipDueDate = json['vipDueDate'];
    vipStatus = json['vipStatus'];
    vipType = json['vipType'];
    vipPayType = json['vip_pay_type'];
    vipThemeType = json['vip_theme_type'];
    vipLabel = json['vip_label'];
    vipAvatarSub = json['vip_avatar_subscript'];
    vipNicknameColor = json['vip_nickname_color'];
    wallet = json['wallet'];
    hasShop = json['has_shop'];
    shopUrl = json['shop_url'];
    isSeniorMember = json['is_senior_member'];
  }

  Map<String, dynamic> toJson() => {
    'isLogin': isLogin ?? false,
    'email_verified': emailVerified,
    'face': face,
    'level_info': levelInfo?.toJson(),
    'mid': mid,
    'mobile_verified': mobileVerified,
    'money': money,
    'moral': moral,
    'official': official,
    'officialVerify': officialVerify,
    'pendant': pendant,
    'scores': scores,
    'uname': uname,
    'vipDueDate': vipDueDate,
    'vipStatus': vipStatus,
    'vipType': vipType,
    'vip_pay_type': vipPayType,
    'vip_theme_type': vipThemeType,
    'vip_label': vipLabel,
    'vip_avatar_subscript': vipAvatarSub,
    'vip_nickname_color': vipNicknameColor,
    'wallet': wallet,
    'has_shop': hasShop,
    'shop_url': shopUrl,
    'is_senior_member': isSeniorMember,
  };

  @override
  int get hashCode => Object.hash(mid, uname, face, money, vipStatus);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserInfoData &&
            isLogin == other.isLogin &&
            face == other.face &&
            levelInfo == other.levelInfo &&
            mid == other.mid &&
            money == other.money &&
            uname == other.uname &&
            vipDueDate == other.vipDueDate &&
            vipStatus == other.vipStatus &&
            isSeniorMember == other.isSeniorMember;
  }
}

class LevelInfo {
  LevelInfo({
    this.currentLevel,
    this.currentMin,
    this.currentExp,
    this.nextExp,
  });

  int? currentLevel;
  int? currentMin;
  int? currentExp;
  int? nextExp;

  LevelInfo.fromJson(Map<String, dynamic> json) {
    currentLevel = json['current_level'];
    currentMin = json['current_min'];
    currentExp = json['current_exp'];
    nextExp = json['current_level'] == 6
        ? json['current_exp']
        : json['next_exp'];
  }

  Map<String, dynamic> toJson() => {
    'current_level': currentLevel,
    'current_min': currentMin,
    'current_exp': currentExp,
    'next_exp': nextExp,
  };

  @override
  int get hashCode => currentExp.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LevelInfo && currentExp == other.currentExp;
  }
}
