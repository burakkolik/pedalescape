// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Pedal Kaçışı: Bisiklet Koşusu';

  @override
  String get appShortName => 'Pedal Kaçışı';

  @override
  String get appTagline => 'Fırtınadan kaç. Durmadan pedalla.';

  @override
  String get splashLoading => 'Lastikler şişiriliyor...';

  @override
  String get splashTip1 => 'Alçak bariyerlerin üstünden atlamak için yukarı kaydır.';

  @override
  String get splashTip2 => 'Boruların ve dalların altından geçmek için aşağı kaydır.';

  @override
  String get splashTip3 => 'Kıl payı kaçışlar kombo göstergeni daha hızlı doldurur.';

  @override
  String get splashTip4 => 'Geliştirmeler her bisiklette kalıcıdır.';

  @override
  String get splashTip5 => 'Her gün uğra — seri ödüllerin giderek büyür.';

  @override
  String get onboardingSkip => 'Geç';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingStart => 'Haydi pedalla!';

  @override
  String get onboardingTitle1 => 'Fırtına geliyor';

  @override
  String get onboardingBody1 => 'Vahşi bir fırtına seni on iki dünya boyunca kovalıyor. Var gücünle pedalla ve asla arkana bakma!';

  @override
  String get onboardingTitle2 => 'Kaydır ve hayatta kal';

  @override
  String get onboardingBody2 => 'Şerit değiştirmek için sola ya da sağa, zıplamak için yukarı, eğilmek için aşağı kaydır.';

  @override
  String get onboardingTitle3 => 'Hayalindeki bisikleti yap';

  @override
  String get onboardingBody3 => 'Jeton topla, on beş eşsiz bisikletin kilidini aç ve her parçasını geliştir.';

  @override
  String get onboardingTitle4 => 'Kendi tarzında sür';

  @override
  String get onboardingBody4 => 'Yüzlerce görevi tamamla ya da uçsuz bucaksız manzaralarda serbestçe gez.';

  @override
  String get menuPlay => 'Oyna';

  @override
  String get menuMissions => 'Görevler';

  @override
  String get menuFreeRide => 'Serbest Sürüş';

  @override
  String get menuEndless => 'Sonsuz Kaçış';

  @override
  String get menuGarage => 'Garaj';

  @override
  String get menuDaily => 'Günlük Ödüller';

  @override
  String get menuTasks => 'Günlük Görevler';

  @override
  String get menuAchievements => 'Başarımlar';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get menuBack => 'Geri';

  @override
  String get menuClose => 'Kapat';

  @override
  String get menuConfirm => 'Onayla';

  @override
  String get menuCancel => 'İptal';

  @override
  String get menuContinue => 'Devam';

  @override
  String get currencyCoins => 'Jeton';

  @override
  String get currencyGems => 'Elmas';

  @override
  String playerLevel(int level) {
    return 'Seviye $level';
  }

  @override
  String xpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String bestDistance(String distance) {
    return 'En iyi: $distance';
  }

  @override
  String get rank1 => 'Çaylak';

  @override
  String get rank2 => 'Pedal Çırağı';

  @override
  String get rank3 => 'Sokak Sürücüsü';

  @override
  String get rank4 => 'Patika Öncüsü';

  @override
  String get rank5 => 'Hız Şeytanı';

  @override
  String get rank6 => 'Fırtına Avcısı';

  @override
  String get rank7 => 'Yol Kaptanı';

  @override
  String get rank8 => 'Dağların Kralı';

  @override
  String get rank9 => 'Efsane';

  @override
  String get rank10 => 'Ölümsüz Pedalcı';

  @override
  String get world1 => 'Güneşli Çayırlar';

  @override
  String get world2 => 'Sonbahar Ormanı';

  @override
  String get world3 => 'Kızıl Kanyon';

  @override
  String get world4 => 'Sahil Yolu';

  @override
  String get world5 => 'Neon Şehir';

  @override
  String get world6 => 'Buzlu Zirveler';

  @override
  String get world7 => 'Zümrüt Orman';

  @override
  String get world8 => 'Kiraz Vadisi';

  @override
  String get world9 => 'Paslı Rıhtım';

  @override
  String get world10 => 'Kayıp Tapınak';

  @override
  String get world11 => 'Volkan Geçidi';

  @override
  String get world12 => 'Yıldızlı Otoyol';

  @override
  String get levelSelectTitle => 'Görevler';

  @override
  String levelNumber(int number) {
    return 'Bölüm $number';
  }

  @override
  String get levelLocked => 'Kilitli';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kilidi açmak için $count yıldız daha topla',
      one: 'Kilidi açmak için 1 yıldız daha topla',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => 'Önce önceki bölümü bitir';

  @override
  String levelLength(String distance) {
    return 'Uzunluk: $distance';
  }

  @override
  String get levelDifficulty => 'Zorluk';

  @override
  String levelRecommendedPower(int power) {
    return 'Önerilen güç: $power';
  }

  @override
  String levelYourPower(int power) {
    return 'Bisikletin: $power';
  }

  @override
  String get levelStart => 'Başla';

  @override
  String get levelObjectives => 'Hedefler';

  @override
  String get objectiveFinish => 'Bitiş çizgisine ulaş';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jeton topla',
      one: '1 jeton topla',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => 'Hiç düşmeden bitir';

  @override
  String objectiveTime(String time) {
    return '$time içinde bitir';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıldız',
      one: '1 yıldız',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return '$done / $total bölüm';
  }

  @override
  String get hudDistance => 'Mesafe';

  @override
  String hudToGo(String distance) {
    return '$distance kaldı';
  }

  @override
  String hudCombo(int multiplier) {
    return 'Kombo x$multiplier';
  }

  @override
  String get hudNearMiss => 'Kıl payı!';

  @override
  String get hudPerfectJump => 'Kusursuz atlayış!';

  @override
  String get hudStormClose => 'Fırtına yaklaştı!';

  @override
  String get hudGo => 'HADİ!';

  @override
  String get hudSpeed => 'km/sa';

  @override
  String get tutorialSwipeSides => 'Şerit değiştirmek için sola ya da sağa kaydır';

  @override
  String get tutorialSwipeUp => 'Zıplamak için yukarı kaydır';

  @override
  String get tutorialSwipeDown => 'Eğilmek için aşağı kaydır';

  @override
  String get tutorialCollect => 'Jetonları ve güçlendiricileri kap!';

  @override
  String get powerMagnet => 'Mıknatıs';

  @override
  String get powerShield => 'Kalkan';

  @override
  String get powerTurbo => 'Turbo';

  @override
  String get powerDoubleCoins => 'Çift Jeton';

  @override
  String get powerGhost => 'Hayalet Sürüş';

  @override
  String get pauseTitle => 'Duraklatıldı';

  @override
  String get pauseResume => 'Devam Et';

  @override
  String get pauseRestart => 'Yeniden Başla';

  @override
  String get pauseQuit => 'Menüye Dön';

  @override
  String get crashTitle => 'Tepetaklak!';

  @override
  String get crashCaught => 'Fırtına seni yakaladı!';

  @override
  String get crashRevive => 'Canlan';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elmasla canlan',
      one: '1 elmasla canlan',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'Pes et';

  @override
  String crashProgress(int percent) {
    return 'Yolun %$percent kadarını geçtin';
  }

  @override
  String get crashSoClose => 'Çok yaklaştın! Bir kez daha?';

  @override
  String get resultLevelComplete => 'Bölüm Tamamlandı!';

  @override
  String get resultRunOver => 'Koşu Bitti';

  @override
  String get resultNewRecord => 'Yeni rekor!';

  @override
  String get resultDistance => 'Mesafe';

  @override
  String get resultCoins => 'Jeton';

  @override
  String get resultTime => 'Süre';

  @override
  String get resultXp => 'XP';

  @override
  String get resultNearMisses => 'Kıl payları';

  @override
  String get resultBestCombo => 'En iyi kombo';

  @override
  String get resultNextLevel => 'Sonraki Bölüm';

  @override
  String get resultRetry => 'Tekrar Dene';

  @override
  String get resultMenu => 'Menü';

  @override
  String resultLevelUp(int level) {
    return 'Seviye atladın! Yeni seviyen: $level';
  }

  @override
  String get resultBonusChest => 'Bonus sandık kazandın!';

  @override
  String get garageTitle => 'Garaj';

  @override
  String get garageBikes => 'Bisikletler';

  @override
  String get garageUpgrades => 'Geliştirmeler';

  @override
  String get garagePaint => 'Boya';

  @override
  String get garageBuy => 'Satın Al';

  @override
  String get garageSelect => 'Bunu Sür';

  @override
  String get garageSelected => 'Seçili';

  @override
  String get garageOwned => 'Sende';

  @override
  String garageRequiresLevel(int level) {
    return 'Seviye $level ile açılır';
  }

  @override
  String get garageNotEnough => 'Yeterli jeton yok';

  @override
  String get garageNotEnoughGems => 'Yeterli elmas yok';

  @override
  String garagePower(int power) {
    return 'Güç $power';
  }

  @override
  String get garageUpgrade => 'Geliştir';

  @override
  String get garageMaxed => 'Maksimum';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Sv $current/$max';
  }

  @override
  String get garagePurchased => 'Satın alındı!';

  @override
  String get garageUpgraded => 'Geliştirildi!';

  @override
  String get garageBuyBikeFirst => 'Geliştirmek için önce bu bisikleti satın al';

  @override
  String get statTopSpeed => 'Maks. hız';

  @override
  String get statAcceleration => 'İvme';

  @override
  String get statHandling => 'Yol tutuş';

  @override
  String get statJump => 'Zıplama';

  @override
  String get statDurability => 'Dayanıklılık';

  @override
  String get statLuck => 'Şans';

  @override
  String get bike1Name => 'Şehir Gezgini';

  @override
  String get bike1Desc => 'Rahat, çelik bir klasik. Yavaş ama hataları affeder.';

  @override
  String get bike2Name => 'Fixie Şimşek';

  @override
  String get bike2Desc => 'Hızlı şerit değişimi için hafif, tek vitesli bisiklet.';

  @override
  String get bike3Name => 'BMX Afacan';

  @override
  String get bike3Desc => 'Küçük tekerler, dev zıplamalar. Numara yapmak için doğdu.';

  @override
  String get bike4Name => 'Patika Keçisi';

  @override
  String get bike4Desc => 'Tümsekleri umursamayan sağlam bir dağ bisikleti.';

  @override
  String get bike5Name => 'Çakıl Göçebesi';

  @override
  String get bike5Desc => 'Her yola uyan dengeli, çok yönlü bir bisiklet.';

  @override
  String get bike6Name => 'Koca Yeti';

  @override
  String get bike6Desc => 'Kazalara gülüp geçen canavar lastikler.';

  @override
  String get bike7Name => 'Volt E-Bisiklet';

  @override
  String get bike7Desc => 'Elektrik desteğiyle göz kamaştıran ivme.';

  @override
  String get bike8Name => 'Karbon Ok';

  @override
  String get bike8Desc => 'Tüy kadar hafif, son hızı müthiş bir yol yarışçısı.';

  @override
  String get bike9Name => 'Yokuş Canavarı';

  @override
  String get bike9Desc => 'Tam süspansiyon ve çelik gibi sinirler.';

  @override
  String get bike10Name => 'Pist Kometi';

  @override
  String get bike10Desc => 'Bir velodrom roketi. Göz açıp kapayana kadar geçer.';

  @override
  String get bike11Name => 'Gizli Gölge';

  @override
  String get bike11Desc => 'Şanslı jetonları çeken mat siyah kadro.';

  @override
  String get bike12Name => 'Titan X';

  @override
  String get bike12Desc => 'İki teker üstünde titanyum zırh.';

  @override
  String get bike13Name => 'Aurora Prototip';

  @override
  String get bike13Desc => 'Parlayan tekerlekli deneysel teknoloji.';

  @override
  String get bike14Name => 'Anka Alevi';

  @override
  String get bike14Desc => 'Ardında ateş izi bırakır. Neredeyse durdurulamaz.';

  @override
  String get bike15Name => 'Göksel Efsane';

  @override
  String get bike15Desc => 'Nihai bisiklet. Ona yalnızca gerçek efsaneler biner.';

  @override
  String get upgradeEngine => 'Vites Oranı';

  @override
  String get upgradeEngineDesc => 'Son hızını artırır.';

  @override
  String get upgradeChain => 'Yarış Zinciri';

  @override
  String get upgradeChainDesc => 'Tam hıza daha çabuk ulaş.';

  @override
  String get upgradeSteering => 'Gidon';

  @override
  String get upgradeSteeringDesc => 'Şerit değiştirmek daha hızlı.';

  @override
  String get upgradeSuspension => 'Süspansiyon';

  @override
  String get upgradeSuspensionDesc => 'Daha yükseğe zıpla, daha yumuşak in.';

  @override
  String get upgradeFrame => 'Güçlü Kadro';

  @override
  String get upgradeFrameDesc => 'Düşmeden önce daha çok darbeye dayan.';

  @override
  String get upgradeTires => 'Tutucu Lastik';

  @override
  String get upgradeTiresDesc => 'Tökezlediğinde daha az yavaşla.';

  @override
  String get upgradeMagnet => 'Mıknatıs Bobini';

  @override
  String get upgradeMagnetDesc => 'Mıknatıs güçlendiricisi daha uzun sürer.';

  @override
  String get upgradeShield => 'Kalkan Jeneratörü';

  @override
  String get upgradeShieldDesc => 'Kalkan güçlendiricisi daha uzun sürer.';

  @override
  String get upgradeTurbo => 'Turbo Takviyesi';

  @override
  String get upgradeTurboDesc => 'Turbo güçlendiricisi daha uzun sürer.';

  @override
  String get upgradeCoinBag => 'Jeton Kesesi';

  @override
  String get upgradeCoinBagDesc => 'Topladığın her jetondan daha fazla kazan.';

  @override
  String get upgradeLuck => 'Uğurlu Tılsım';

  @override
  String get upgradeLuckDesc => 'Güçlendiriciler ve elmaslar daha sık çıkar.';

  @override
  String get upgradeLights => 'Far';

  @override
  String get upgradeLightsDesc => 'Geceleri engelleri daha uzaktan gör.';

  @override
  String get paintName1 => 'Fabrika';

  @override
  String get paintName2 => 'Kızıl';

  @override
  String get paintName3 => 'Okyanus';

  @override
  String get paintName4 => 'Limon';

  @override
  String get paintName5 => 'Gün Batımı';

  @override
  String get paintName6 => 'Gece Yarısı';

  @override
  String get paintName7 => 'Altın';

  @override
  String get paintName8 => 'Şeker';

  @override
  String get dailyTitle => 'Günlük Ödüller';

  @override
  String dailyDay(int day) {
    return '$day. Gün';
  }

  @override
  String get dailyClaim => 'Al';

  @override
  String get dailyClaimed => 'Alındı';

  @override
  String get dailyComeBack => 'Daha büyük ödül için yarın yine gel!';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günlük seri',
      one: '1 günlük seri',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => 'Ödül hazır!';

  @override
  String dailyNextIn(String time) {
    return 'Sonraki ödül: $time';
  }

  @override
  String get spinTitle => 'Şans Çarkı';

  @override
  String get spinButton => 'Çevir!';

  @override
  String get spinFree => 'Bedava çevirme hakkın var';

  @override
  String spinUsed(String time) {
    return 'Sonraki bedava çevirme: $time';
  }

  @override
  String spinWon(String reward) {
    return '$reward kazandın!';
  }

  @override
  String get chestTitle => 'Gizemli Sandık';

  @override
  String get chestOpen => 'Açmak için dokun';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sandık seni bekliyor',
      one: '1 sandık seni bekliyor',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'Günlük Görevler';

  @override
  String tasksRefresh(String time) {
    return 'Yeni görevler: $time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jeton topla',
      one: '1 jeton topla',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return 'Toplam $distance sür';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count engelin üstünden atla',
      one: '1 engelin üstünden atla',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count engelin altından geç',
      one: '1 engelin altından geç',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kıl payı kaçış yap',
      one: '1 kıl payı kaçış yap',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count güçlendirici kullan',
      one: '1 güçlendirici kullan',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bölüm tamamla',
      one: '1 bölüm tamamla',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'Serbest Sürüş\'te $distance gez';
  }

  @override
  String get taskClaim => 'Al';

  @override
  String get taskDone => 'Bitti';

  @override
  String get taskAllDone => 'Tüm görevler tamam! Bonus açıldı.';

  @override
  String get achievementsTitle => 'Başarımlar';

  @override
  String get achDistance => 'Uzun Yolcu';

  @override
  String achDistanceDesc(String distance) {
    return 'Toplam $distance sür';
  }

  @override
  String get achCoins => 'Hazine Avcısı';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toplam $count jeton topla',
      one: 'Toplam 1 jeton topla',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'Uçuş Vakti';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kez zıpla',
      one: '1 kez zıpla',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'Görev Ustası';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bölüm tamamla',
      one: '1 bölüm tamamla',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'Yıldız Avcısı';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıldız kazan',
      one: '1 yıldız kazan',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'Koleksiyoncu';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bisiklete sahip ol',
      one: '1 bisiklete sahip ol',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'Tamirci';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geliştirme satın al',
      one: '1 geliştirme satın al',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => 'Gözü Kara';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kıl payı kaçış yap',
      one: '1 kıl payı kaçış yap',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => 'Sadık Sürücü';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün üst üste giriş yap',
      one: '1 gün üst üste giriş yap',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => 'Kaçış Ustası';

  @override
  String achEndlessDesc(String distance) {
    return 'Tek bir Sonsuz Kaçış koşusunda $distance yol al';
  }

  @override
  String achTier(int tier) {
    return 'Kademe $tier';
  }

  @override
  String get achReward => 'Ödül';

  @override
  String get achClaim => 'Al';

  @override
  String get achCompleted => 'Tamamlandı';

  @override
  String get freeRideTitle => 'Serbest Sürüş';

  @override
  String get freeRideWorld => 'Dünya';

  @override
  String get freeRideTime => 'Günün saati';

  @override
  String get freeRideMorning => 'Sabah';

  @override
  String get freeRideNoon => 'Öğle';

  @override
  String get freeRideSunset => 'Gün batımı';

  @override
  String get freeRideNight => 'Gece';

  @override
  String get freeRideCycle => 'Gece-gündüz döngüsü';

  @override
  String get freeRideWeather => 'Hava';

  @override
  String get weatherClear => 'Açık';

  @override
  String get weatherRain => 'Yağmur';

  @override
  String get weatherSnow => 'Kar';

  @override
  String get weatherFog => 'Sis';

  @override
  String get weatherLeaves => 'Dökülen yapraklar';

  @override
  String get freeRideTraffic => 'Trafik';

  @override
  String get freeRideTrafficNone => 'Yok';

  @override
  String get freeRideTrafficLight => 'Az';

  @override
  String get freeRideTrafficHeavy => 'Yoğun';

  @override
  String get freeRideStart => 'Sürüşe başla';

  @override
  String get freeRideHint => 'Fırtına yok, baskı yok. Sürüşün tadını çıkar, yol boyunca jeton topla.';

  @override
  String get freeRideLocked => 'Kilidi açmak için Görevler\'de bu dünyaya ulaş';

  @override
  String get endlessTitle => 'Sonsuz Kaçış';

  @override
  String get endlessHint => 'Fırtına seni yakalamadan ne kadar uzağa gidebilirsin?';

  @override
  String get endlessBest => 'Kişisel rekor';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSystem => 'Telefon dili';

  @override
  String get settingsSound => 'Ses efektleri';

  @override
  String get settingsMusic => 'Müzik';

  @override
  String get settingsVibration => 'Titreşim';

  @override
  String get settingsGraphics => 'Grafik kalitesi';

  @override
  String get graphicsLow => 'Düşük';

  @override
  String get graphicsMedium => 'Orta';

  @override
  String get graphicsHigh => 'Yüksek';

  @override
  String get settingsSensitivity => 'Kaydırma hassasiyeti';

  @override
  String get settingsShowTutorial => 'Eğitimi tekrar göster';

  @override
  String get settingsReset => 'İlerlemeyi sıfırla';

  @override
  String get settingsResetConfirm => 'Tüm jetonlar, bisikletler ve bölümler silinecek. Emin misin?';

  @override
  String get settingsResetDone => 'İlerleme sıfırlandı';

  @override
  String settingsVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get settingsOn => 'Açık';

  @override
  String get settingsOff => 'Kapalı';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jeton',
      one: '1 jeton',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elmas',
      one: '1 elmas',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'Gizemli sandık';

  @override
  String get rewardCollect => 'Topla';

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
    return '$hours sa $minutes dk';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'Tekrar hoş geldin, sürücü!';

  @override
  String offlineEarnings(String count) {
    return 'Sen yokken bisiklet ekibin $count jeton buldu';
  }

  @override
  String get newBikeAvailable => 'Garajda yeni bir bisiklet seni bekliyor!';

  @override
  String get almostThere => 'Az kaldı!';

  @override
  String get keepGoing => 'Devam et!';

  @override
  String unlockedWorld(String world) {
    return 'Yeni dünya açıldı: $world';
  }
}
