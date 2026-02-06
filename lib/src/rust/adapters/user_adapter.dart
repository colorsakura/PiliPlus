import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/src/rust/models/user.dart' as rust;

/// Adapter for converting Rust UserInfo/UserStats to Flutter UserInfoData/UserStat.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/)
///
/// Key conversions:
/// - `name` (Rust) → `uname` (Flutter)
/// - `vip_status` (Rust) → `vipStatus`/`vipType` (Flutter separate fields)
/// - `money` (Rust: f64) → `money` (Flutter: double)
/// - `level_info` (Rust) → `levelInfo` (Flutter)
/// - `dynamic_count` (Rust) → `dynamicCount` (Flutter)
class UserAdapter {
  /// Convert Rust UserInfo to Flutter UserInfoData.
  ///
  /// Provides sensible defaults for fields not present in the Rust model:
  /// - `isLogin`: Set to null (determined by caller)
  /// - `official`, `officialVerify`, `pendant`, `vipLabel`, `wallet`: Set to null
  /// - All other optional fields: Mapped from Rust or set to defaults
  static UserInfoData fromRustUserInfo(rust.UserInfo rustUser) {
    return UserInfoData(
      isLogin: null, // Determined by caller based on whether API call succeeded
      emailVerified: rustUser.emailVerified,
      face: rustUser.face,
      levelInfo: LevelInfo(
        currentLevel: rustUser.levelInfo.currentLevel,
        currentMin: rustUser.levelInfo.currentMin,
        currentExp: rustUser.levelInfo.currentExp,
        nextExp: rustUser.levelInfo.nextExp,
      ),
      mid: rustUser.mid,
      mobileVerified: rustUser.mobileVerified,
      money: rustUser.money,
      moral: rustUser.moral,
      official: null, // Complex JSON object not mapped in simplified Rust model
      officialVerify: null, // Complex JSON object not mapped in simplified Rust model
      pendant: null, // Complex JSON object not mapped in simplified Rust model
      scores: rustUser.scores,
      uname: rustUser.name,
      vipDueDate: rustUser.vipDueDate,
      vipStatus: rustUser.vipStatus.status,
      vipType: rustUser.vipStatus.vipType,
      vipPayType: rustUser.vipPayType,
      vipThemeType: rustUser.vipThemeType,
      vipLabel: null, // Complex JSON object not mapped in simplified Rust model
      vipAvatarSub: rustUser.vipAvatarSub,
      vipNicknameColor: rustUser.vipNicknameColor,
      wallet: null, // Complex JSON object not mapped in simplified Rust model
      hasShop: rustUser.hasShop,
      shopUrl: rustUser.shopUrl,
      isSeniorMember: rustUser.isSeniorMember,
    );
  }

  /// Convert Rust UserStats to Flutter UserStat.
  ///
  /// Maps all fields directly:
  /// - `following` → `following`
  /// - `follower` → `follower`
  /// - `dynamic_count` → `dynamicCount`
  static UserStat fromRustUserStats(rust.UserStats rustStats) {
    return UserStat(
      following: rustStats.following,
      follower: rustStats.follower,
      dynamicCount: rustStats.dynamicCount,
    );
  }
}
