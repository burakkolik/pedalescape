// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Pedal Escape: Kabur Bersepeda';

  @override
  String get appShortName => 'Pedal Escape';

  @override
  String get appTagline => 'Lolos dari badai. Gowes tanpa henti.';

  @override
  String get splashLoading => 'Memompa ban...';

  @override
  String get splashTip1 => 'Geser ke atas untuk melompati rintangan rendah.';

  @override
  String get splashTip2 => 'Geser ke bawah untuk menunduk di bawah pipa dan dahan.';

  @override
  String get splashTip3 => 'Nyaris kena bikin meter kombo terisi lebih cepat.';

  @override
  String get splashTip4 => 'Upgrade tersimpan di setiap sepeda selamanya.';

  @override
  String get splashTip5 => 'Kembali tiap hari — hadiah beruntunmu makin besar.';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingNext => 'Lanjut';

  @override
  String get onboardingStart => 'Ayo gowes!';

  @override
  String get onboardingTitle1 => 'Badai datang';

  @override
  String get onboardingBody1 => 'Badai dahsyat mengejarmu melintasi dua belas dunia. Kayuh sekuat tenaga dan jangan menoleh!';

  @override
  String get onboardingTitle2 => 'Geser untuk bertahan';

  @override
  String get onboardingBody2 => 'Geser kiri atau kanan untuk pindah jalur, ke atas untuk melompat, dan ke bawah untuk menunduk.';

  @override
  String get onboardingTitle3 => 'Rakit sepeda impianmu';

  @override
  String get onboardingBody3 => 'Kumpulkan koin, buka lima belas sepeda unik, dan upgrade setiap bagiannya.';

  @override
  String get onboardingTitle4 => 'Gowes sesukamu';

  @override
  String get onboardingBody4 => 'Selesaikan ratusan misi atau bersantai menikmati pemandangan tanpa akhir.';

  @override
  String get menuPlay => 'Main';

  @override
  String get menuMissions => 'Misi';

  @override
  String get menuFreeRide => 'Gowes Bebas';

  @override
  String get menuEndless => 'Kabur Tanpa Akhir';

  @override
  String get menuGarage => 'Garasi';

  @override
  String get menuDaily => 'Hadiah Harian';

  @override
  String get menuTasks => 'Tugas Harian';

  @override
  String get menuAchievements => 'Pencapaian';

  @override
  String get menuSettings => 'Pengaturan';

  @override
  String get menuBack => 'Kembali';

  @override
  String get menuClose => 'Tutup';

  @override
  String get menuConfirm => 'Konfirmasi';

  @override
  String get menuCancel => 'Batal';

  @override
  String get menuContinue => 'Lanjutkan';

  @override
  String get currencyCoins => 'Koin';

  @override
  String get currencyGems => 'Permata';

  @override
  String playerLevel(int level) {
    return 'Level $level';
  }

  @override
  String xpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String bestDistance(String distance) {
    return 'Terbaik: $distance';
  }

  @override
  String get rank1 => 'Pemula';

  @override
  String get rank2 => 'Tukang Kayuh';

  @override
  String get rank3 => 'Jagoan Jalanan';

  @override
  String get rank4 => 'Perintis Jalur';

  @override
  String get rank5 => 'Iblis Kecepatan';

  @override
  String get rank6 => 'Pemburu Badai';

  @override
  String get rank7 => 'Kapten Jalanan';

  @override
  String get rank8 => 'Raja Gunung';

  @override
  String get rank9 => 'Legenda';

  @override
  String get rank10 => 'Kayuh Abadi';

  @override
  String get world1 => 'Padang Cerah';

  @override
  String get world2 => 'Hutan Musim Gugur';

  @override
  String get world3 => 'Ngarai Merah';

  @override
  String get world4 => 'Jalan Pesisir';

  @override
  String get world5 => 'Kota Neon';

  @override
  String get world6 => 'Puncak Beku';

  @override
  String get world7 => 'Rimba Zamrud';

  @override
  String get world8 => 'Lembah Sakura';

  @override
  String get world9 => 'Dermaga Karat';

  @override
  String get world10 => 'Kuil yang Hilang';

  @override
  String get world11 => 'Celah Gunung Api';

  @override
  String get world12 => 'Jalur Cahaya Bintang';

  @override
  String get levelSelectTitle => 'Misi';

  @override
  String levelNumber(int number) {
    return 'Level $number';
  }

  @override
  String get levelLocked => 'Terkunci';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kumpulkan $count bintang lagi untuk membuka',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => 'Selesaikan level sebelumnya dulu';

  @override
  String levelLength(String distance) {
    return 'Panjang: $distance';
  }

  @override
  String get levelDifficulty => 'Kesulitan';

  @override
  String levelRecommendedPower(int power) {
    return 'Kekuatan disarankan: $power';
  }

  @override
  String levelYourPower(int power) {
    return 'Sepedamu: $power';
  }

  @override
  String get levelStart => 'Mulai';

  @override
  String get levelObjectives => 'Target';

  @override
  String get objectiveFinish => 'Capai garis finis';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kumpulkan $count koin',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => 'Finis tanpa jatuh';

  @override
  String objectiveTime(String time) {
    return 'Finis dalam $time';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bintang',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return '$done / $total level';
  }

  @override
  String get hudDistance => 'Jarak';

  @override
  String hudToGo(String distance) {
    return '$distance lagi';
  }

  @override
  String hudCombo(int multiplier) {
    return 'Kombo x$multiplier';
  }

  @override
  String get hudNearMiss => 'Nyaris kena!';

  @override
  String get hudPerfectJump => 'Lompatan sempurna!';

  @override
  String get hudStormClose => 'Badai makin dekat!';

  @override
  String get hudGo => 'GAS!';

  @override
  String get hudSpeed => 'km/j';

  @override
  String get tutorialSwipeSides => 'Geser kiri atau kanan untuk pindah jalur';

  @override
  String get tutorialSwipeUp => 'Geser ke atas untuk melompat';

  @override
  String get tutorialSwipeDown => 'Geser ke bawah untuk menunduk';

  @override
  String get tutorialCollect => 'Ambil koin dan power-up!';

  @override
  String get powerMagnet => 'Magnet';

  @override
  String get powerShield => 'Perisai';

  @override
  String get powerTurbo => 'Turbo';

  @override
  String get powerDoubleCoins => 'Koin Ganda';

  @override
  String get powerGhost => 'Mode Hantu';

  @override
  String get pauseTitle => 'Jeda';

  @override
  String get pauseResume => 'Lanjutkan';

  @override
  String get pauseRestart => 'Ulangi';

  @override
  String get pauseQuit => 'Keluar ke Menu';

  @override
  String get crashTitle => 'Jatuh!';

  @override
  String get crashCaught => 'Badai menangkapmu!';

  @override
  String get crashRevive => 'Bangkit';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bangkit dengan $count permata',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'Menyerah';

  @override
  String crashProgress(int percent) {
    return 'Kamu menempuh $percent% perjalanan';
  }

  @override
  String get crashSoClose => 'Sedikit lagi! Coba sekali lagi?';

  @override
  String get resultLevelComplete => 'Level Selesai!';

  @override
  String get resultRunOver => 'Perjalanan Usai';

  @override
  String get resultNewRecord => 'Rekor baru!';

  @override
  String get resultDistance => 'Jarak';

  @override
  String get resultCoins => 'Koin';

  @override
  String get resultTime => 'Waktu';

  @override
  String get resultXp => 'XP';

  @override
  String get resultNearMisses => 'Nyaris kena';

  @override
  String get resultBestCombo => 'Kombo terbaik';

  @override
  String get resultNextLevel => 'Level Berikutnya';

  @override
  String get resultRetry => 'Ulangi';

  @override
  String get resultMenu => 'Menu';

  @override
  String resultLevelUp(int level) {
    return 'Naik level! Sekarang kamu level $level';
  }

  @override
  String get resultBonusChest => 'Dapat peti bonus!';

  @override
  String get garageTitle => 'Garasi';

  @override
  String get garageBikes => 'Sepeda';

  @override
  String get garageUpgrades => 'Upgrade';

  @override
  String get garagePaint => 'Cat';

  @override
  String get garageBuy => 'Beli';

  @override
  String get garageSelect => 'Pakai ini';

  @override
  String get garageSelected => 'Dipakai';

  @override
  String get garageOwned => 'Dimiliki';

  @override
  String garageRequiresLevel(int level) {
    return 'Terbuka di level $level';
  }

  @override
  String get garageNotEnough => 'Koin tidak cukup';

  @override
  String get garageNotEnoughGems => 'Permata tidak cukup';

  @override
  String garagePower(int power) {
    return 'Kekuatan $power';
  }

  @override
  String get garageUpgrade => 'Upgrade';

  @override
  String get garageMaxed => 'Maks';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Lv $current/$max';
  }

  @override
  String get garagePurchased => 'Terbeli!';

  @override
  String get garageUpgraded => 'Di-upgrade!';

  @override
  String get garageBuyBikeFirst => 'Beli sepeda ini untuk meng-upgrade';

  @override
  String get statTopSpeed => 'Kecepatan maks';

  @override
  String get statAcceleration => 'Akselerasi';

  @override
  String get statHandling => 'Kendali';

  @override
  String get statJump => 'Lompatan';

  @override
  String get statDurability => 'Ketahanan';

  @override
  String get statLuck => 'Hoki';

  @override
  String get bike1Name => 'Penjelajah Kota';

  @override
  String get bike1Desc => 'Klasik baja yang nyaman. Lambat tapi mudah dikendalikan.';

  @override
  String get bike2Name => 'Fixie Kilat';

  @override
  String get bike2Desc => 'Single-speed ringan untuk pindah jalur secepat kilat.';

  @override
  String get bike3Name => 'BMX Bandel';

  @override
  String get bike3Desc => 'Roda mungil, lompatan raksasa. Lahir untuk atraksi.';

  @override
  String get bike4Name => 'Kambing Gunung';

  @override
  String get bike4Desc => 'Sepeda gunung tangguh yang cuek pada jalan bergelombang.';

  @override
  String get bike5Name => 'Pengembara Gravel';

  @override
  String get bike5Desc => 'Serbabisa dan seimbang untuk segala jenis jalan.';

  @override
  String get bike6Name => 'Yeti Gembul';

  @override
  String get bike6Desc => 'Ban monster yang menertawakan tabrakan.';

  @override
  String get bike7Name => 'E-Bike Volt';

  @override
  String get bike7Desc => 'Bantuan listrik untuk akselerasi secepat kilat.';

  @override
  String get bike8Name => 'Panah Karbon';

  @override
  String get bike8Desc => 'Sepeda balap superringan dengan kecepatan puncak tinggi.';

  @override
  String get bike9Name => 'Monster Turunan';

  @override
  String get bike9Desc => 'Suspensi penuh dan nyali baja.';

  @override
  String get bike10Name => 'Komet Trek';

  @override
  String get bike10Desc => 'Roket velodrom. Sekali kedip, dia sudah lewat.';

  @override
  String get bike11Name => 'Bayangan Senyap';

  @override
  String get bike11Desc => 'Rangka hitam doff yang menarik koin keberuntungan.';

  @override
  String get bike12Name => 'Titan X';

  @override
  String get bike12Desc => 'Zirah titanium di atas dua roda.';

  @override
  String get bike13Name => 'Prototipe Aurora';

  @override
  String get bike13Desc => 'Teknologi eksperimental dengan roda bercahaya.';

  @override
  String get bike14Name => 'Phoenix Membara';

  @override
  String get bike14Desc => 'Meninggalkan jejak api. Nyaris tak terhentikan.';

  @override
  String get bike15Name => 'Legenda Langit';

  @override
  String get bike15Desc => 'Sepeda pamungkas. Hanya legenda sejati yang menungganginya.';

  @override
  String get upgradeEngine => 'Rasio Gigi';

  @override
  String get upgradeEngineDesc => 'Menaikkan kecepatan maksimal.';

  @override
  String get upgradeChain => 'Rantai Balap';

  @override
  String get upgradeChainDesc => 'Capai kecepatan penuh lebih cepat.';

  @override
  String get upgradeSteering => 'Kemudi';

  @override
  String get upgradeSteeringDesc => 'Pindah jalur lebih gesit.';

  @override
  String get upgradeSuspension => 'Suspensi';

  @override
  String get upgradeSuspensionDesc => 'Lompat lebih tinggi, mendarat lebih empuk.';

  @override
  String get upgradeFrame => 'Rangka Kokoh';

  @override
  String get upgradeFrameDesc => 'Tahan lebih banyak benturan sebelum jatuh.';

  @override
  String get upgradeTires => 'Ban Cengkeram';

  @override
  String get upgradeTiresDesc => 'Tak banyak melambat saat tersandung.';

  @override
  String get upgradeMagnet => 'Kumparan Magnet';

  @override
  String get upgradeMagnetDesc => 'Power-up Magnet bertahan lebih lama.';

  @override
  String get upgradeShield => 'Generator Perisai';

  @override
  String get upgradeShieldDesc => 'Power-up Perisai bertahan lebih lama.';

  @override
  String get upgradeTurbo => 'Pendorong Turbo';

  @override
  String get upgradeTurboDesc => 'Power-up Turbo bertahan lebih lama.';

  @override
  String get upgradeCoinBag => 'Kantong Koin';

  @override
  String get upgradeCoinBagDesc => 'Dapat lebih banyak koin dari setiap ambilan.';

  @override
  String get upgradeLuck => 'Jimat Hoki';

  @override
  String get upgradeLuckDesc => 'Power-up dan permata lebih sering muncul.';

  @override
  String get upgradeLights => 'Lampu Depan';

  @override
  String get upgradeLightsDesc => 'Lihat rintangan dari lebih jauh saat malam.';

  @override
  String get paintName1 => 'Standar';

  @override
  String get paintName2 => 'Merah Tua';

  @override
  String get paintName3 => 'Samudra';

  @override
  String get paintName4 => 'Limau';

  @override
  String get paintName5 => 'Senja';

  @override
  String get paintName6 => 'Tengah Malam';

  @override
  String get paintName7 => 'Emas';

  @override
  String get paintName8 => 'Permen';

  @override
  String get dailyTitle => 'Hadiah Harian';

  @override
  String dailyDay(int day) {
    return 'Hari $day';
  }

  @override
  String get dailyClaim => 'Klaim';

  @override
  String get dailyClaimed => 'Diklaim';

  @override
  String get dailyComeBack => 'Kembali besok untuk hadiah lebih besar!';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari beruntun',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => 'Hadiah siap!';

  @override
  String dailyNextIn(String time) {
    return 'Hadiah berikutnya dalam $time';
  }

  @override
  String get spinTitle => 'Roda Hoki';

  @override
  String get spinButton => 'Putar!';

  @override
  String get spinFree => 'Putaran gratis tersedia';

  @override
  String spinUsed(String time) {
    return 'Putaran gratis berikutnya dalam $time';
  }

  @override
  String spinWon(String reward) {
    return 'Kamu dapat $reward!';
  }

  @override
  String get chestTitle => 'Peti Misteri';

  @override
  String get chestOpen => 'Ketuk untuk membuka';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peti menunggu',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'Tugas Harian';

  @override
  String tasksRefresh(String time) {
    return 'Tugas baru dalam $time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kumpulkan $count koin',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return 'Gowes total $distance';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lompati $count rintangan',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menunduk di bawah $count rintangan',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nyaris kena $count kali',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gunakan $count power-up',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Selesaikan $count level',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'Gowes santai $distance di Gowes Bebas';
  }

  @override
  String get taskClaim => 'Klaim';

  @override
  String get taskDone => 'Selesai';

  @override
  String get taskAllDone => 'Semua tugas selesai! Bonus terbuka.';

  @override
  String get achievementsTitle => 'Pencapaian';

  @override
  String get achDistance => 'Penempuh Jauh';

  @override
  String achDistanceDesc(String distance) {
    return 'Gowes total $distance';
  }

  @override
  String get achCoins => 'Pemburu Harta';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kumpulkan total $count koin',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'Raja Udara';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Melompat $count kali',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'Master Misi';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Selesaikan $count level',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'Kolektor Bintang';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raih $count bintang',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'Kolektor';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Miliki $count sepeda',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'Mekanik';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Beli $count upgrade',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => 'Pemberani';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nyaris kena $count kali',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => 'Pesepeda Setia';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Login $count hari berturut-turut',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => 'Ahli Kabur';

  @override
  String achEndlessDesc(String distance) {
    return 'Capai $distance dalam satu sesi Tanpa Akhir';
  }

  @override
  String achTier(int tier) {
    return 'Tingkat $tier';
  }

  @override
  String get achReward => 'Hadiah';

  @override
  String get achClaim => 'Klaim';

  @override
  String get achCompleted => 'Selesai';

  @override
  String get freeRideTitle => 'Gowes Bebas';

  @override
  String get freeRideWorld => 'Dunia';

  @override
  String get freeRideTime => 'Waktu';

  @override
  String get freeRideMorning => 'Pagi';

  @override
  String get freeRideNoon => 'Siang';

  @override
  String get freeRideSunset => 'Senja';

  @override
  String get freeRideNight => 'Malam';

  @override
  String get freeRideCycle => 'Siklus siang & malam';

  @override
  String get freeRideWeather => 'Cuaca';

  @override
  String get weatherClear => 'Cerah';

  @override
  String get weatherRain => 'Hujan';

  @override
  String get weatherSnow => 'Salju';

  @override
  String get weatherFog => 'Kabut';

  @override
  String get weatherLeaves => 'Daun berguguran';

  @override
  String get freeRideTraffic => 'Lalu lintas';

  @override
  String get freeRideTrafficNone => 'Tidak ada';

  @override
  String get freeRideTrafficLight => 'Sepi';

  @override
  String get freeRideTrafficHeavy => 'Padat';

  @override
  String get freeRideStart => 'Mulai gowes';

  @override
  String get freeRideHint => 'Tanpa badai, tanpa tekanan. Nikmati perjalanan dan kumpulkan koin di sepanjang jalan.';

  @override
  String get freeRideLocked => 'Capai dunia ini di Misi untuk membukanya';

  @override
  String get endlessTitle => 'Kabur Tanpa Akhir';

  @override
  String get endlessHint => 'Seberapa jauh kamu bisa melaju sebelum badai menangkapmu?';

  @override
  String get endlessBest => 'Rekor pribadi';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSystem => 'Bahasa ponsel';

  @override
  String get settingsSound => 'Efek suara';

  @override
  String get settingsMusic => 'Musik';

  @override
  String get settingsVibration => 'Getaran';

  @override
  String get settingsGraphics => 'Kualitas grafis';

  @override
  String get graphicsLow => 'Rendah';

  @override
  String get graphicsMedium => 'Sedang';

  @override
  String get graphicsHigh => 'Tinggi';

  @override
  String get settingsSensitivity => 'Sensitivitas geser';

  @override
  String get settingsShowTutorial => 'Tampilkan tutorial lagi';

  @override
  String get settingsReset => 'Reset progres';

  @override
  String get settingsResetConfirm => 'Ini akan menghapus semua koin, sepeda, dan level. Kamu yakin?';

  @override
  String get settingsResetDone => 'Progres direset';

  @override
  String settingsVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get settingsOn => 'Aktif';

  @override
  String get settingsOff => 'Mati';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count koin',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count permata',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'Peti misteri';

  @override
  String get rewardCollect => 'Ambil';

  @override
  String distanceMeters(String value) {
    return '$value m';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String timeHoursMinutes(int hours, int minutes) {
    return '${hours}j ${minutes}m';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'Selamat datang kembali, pesepeda!';

  @override
  String offlineEarnings(String count) {
    return 'Kru sepedamu menemukan $count koin selama kamu pergi';
  }

  @override
  String get newBikeAvailable => 'Sepeda baru menunggu di garasi!';

  @override
  String get almostThere => 'Hampir sampai!';

  @override
  String get keepGoing => 'Terus kayuh!';

  @override
  String unlockedWorld(String world) {
    return 'Dunia baru terbuka: $world';
  }
}
