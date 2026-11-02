/// Convenience accessors for localized strings and locale-aware formatting.
///
/// * `context.l10n` → [AppLocalizations]
/// * `l10n.worldName(i)`, `bikeName(id)`, `upgradeName(type)` … map catalog
///   ids to ARB keys in one place.
/// * `l10n.formatDistance(m)`, `formatDuration(s)`, `compact(n)` use `intl`
///   with the current locale.
library;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../game/catalog/upgrades/upgrade_type.dart';
import 'generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsX on AppLocalizations {
  String get _intlLocale {
    final name = localeName.replaceAll('-', '_');
    return Intl.verifiedLocale(name, NumberFormat.localeExists,
            onFailure: (_) => 'en') ??
        'en';
  }

  // ---- Catalog names -------------------------------------------------------

  /// 0-based world index → name.
  String worldName(int index) => switch (index) {
        0 => world1,
        1 => world2,
        2 => world3,
        3 => world4,
        4 => world5,
        5 => world6,
        6 => world7,
        7 => world8,
        8 => world9,
        9 => world10,
        10 => world11,
        _ => world12,
      };

  /// 1-based bike id → name.
  String bikeName(int id) => switch (id) {
        1 => bike1Name,
        2 => bike2Name,
        3 => bike3Name,
        4 => bike4Name,
        5 => bike5Name,
        6 => bike6Name,
        7 => bike7Name,
        8 => bike8Name,
        9 => bike9Name,
        10 => bike10Name,
        11 => bike11Name,
        12 => bike12Name,
        13 => bike13Name,
        14 => bike14Name,
        _ => bike15Name,
      };

  String bikeDesc(int id) => switch (id) {
        1 => bike1Desc,
        2 => bike2Desc,
        3 => bike3Desc,
        4 => bike4Desc,
        5 => bike5Desc,
        6 => bike6Desc,
        7 => bike7Desc,
        8 => bike8Desc,
        9 => bike9Desc,
        10 => bike10Desc,
        11 => bike11Desc,
        12 => bike12Desc,
        13 => bike13Desc,
        14 => bike14Desc,
        _ => bike15Desc,
      };

  String upgradeName(UpgradeType type) => switch (type) {
        UpgradeType.gearRatio => upgradeEngine,
        UpgradeType.chain => upgradeChain,
        UpgradeType.steering => upgradeSteering,
        UpgradeType.suspension => upgradeSuspension,
        UpgradeType.frame => upgradeFrame,
        UpgradeType.tires => upgradeTires,
        UpgradeType.magnet => upgradeMagnet,
        UpgradeType.shield => upgradeShield,
        UpgradeType.turbo => upgradeTurbo,
        UpgradeType.coinPouch => upgradeCoinBag,
        UpgradeType.luck => upgradeLuck,
        UpgradeType.headlight => upgradeLights,
      };

  String upgradeDesc(UpgradeType type) => switch (type) {
        UpgradeType.gearRatio => upgradeEngineDesc,
        UpgradeType.chain => upgradeChainDesc,
        UpgradeType.steering => upgradeSteeringDesc,
        UpgradeType.suspension => upgradeSuspensionDesc,
        UpgradeType.frame => upgradeFrameDesc,
        UpgradeType.tires => upgradeTiresDesc,
        UpgradeType.magnet => upgradeMagnetDesc,
        UpgradeType.shield => upgradeShieldDesc,
        UpgradeType.turbo => upgradeTurboDesc,
        UpgradeType.coinPouch => upgradeCoinBagDesc,
        UpgradeType.luck => upgradeLuckDesc,
        UpgradeType.headlight => upgradeLightsDesc,
      };

  /// Rank 1..10 → title.
  String rankName(int rank) => switch (rank) {
        <= 1 => rank1,
        2 => rank2,
        3 => rank3,
        4 => rank4,
        5 => rank5,
        6 => rank6,
        7 => rank7,
        8 => rank8,
        9 => rank9,
        _ => rank10,
      };

  /// 0-based paint index → name.
  String paintName(int index) => switch (index) {
        <= 0 => paintName1,
        1 => paintName2,
        2 => paintName3,
        3 => paintName4,
        4 => paintName5,
        5 => paintName6,
        6 => paintName7,
        _ => paintName8,
      };

  // ---- Number formatting -----------------------------------------------------

  /// Grouped integer, e.g. 12,500 / 12.500 depending on locale.
  String formatInt(num value) =>
      NumberFormat.decimalPattern(_intlLocale).format(value.round());

  /// Compact number, e.g. 1.2K / 1,2 Mio.
  String compact(num value) {
    if (value.abs() < 10000) return formatInt(value);
    return NumberFormat.compact(locale: _intlLocale).format(value);
  }

  /// Meters below 1 km, otherwise kilometers with one decimal.
  String formatDistance(double meters) {
    if (meters < 1000) {
      return distanceMeters(formatInt(meters.floor()));
    }
    final km = meters / 1000;
    final pattern = km >= 100 ? '#,##0' : '#,##0.0';
    return distanceKilometers(NumberFormat(pattern, _intlLocale).format(km));
  }

  /// `m:ss` below one hour, otherwise `Xh Ym`.
  String formatDuration(Duration d) {
    if (d.isNegative) d = Duration.zero;
    if (d.inHours >= 1) {
      return timeHoursMinutes(d.inHours, d.inMinutes % 60);
    }
    final m = d.inMinutes.toString();
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return timeMinutesSeconds(m, s);
  }

  String formatSeconds(num seconds) =>
      formatDuration(Duration(milliseconds: (seconds * 1000).round()));
}
