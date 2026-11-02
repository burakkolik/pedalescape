// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Pedal Escape: Rowerowa Pogoń';

  @override
  String get appShortName => 'Pedal Escape';

  @override
  String get appTagline => 'Ucieknij burzy. Pedałuj bez końca.';

  @override
  String get splashLoading => 'Pompujemy opony...';

  @override
  String get splashTip1 => 'Przesuń w górę, by przeskoczyć niskie bariery.';

  @override
  String get splashTip2 => 'Przesuń w dół, by schylić się pod rurami i gałęziami.';

  @override
  String get splashTip3 => 'Mijanki o włos szybciej ładują pasek kombo.';

  @override
  String get splashTip4 => 'Ulepszenia zostają przy każdym rowerze na zawsze.';

  @override
  String get splashTip5 => 'Wracaj codziennie — nagrody za serię rosną.';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingStart => 'Jedziemy!';

  @override
  String get onboardingTitle1 => 'Nadciąga burza';

  @override
  String get onboardingBody1 => 'Szalona burza goni cię przez dwanaście światów. Pedałuj ile sił i nie oglądaj się za siebie!';

  @override
  String get onboardingTitle2 => 'Przesuwaj, by przetrwać';

  @override
  String get onboardingBody2 => 'Przesuń w lewo lub prawo, by zmienić pas, w górę, by skoczyć, i w dół, by się schylić.';

  @override
  String get onboardingTitle3 => 'Zbuduj rower marzeń';

  @override
  String get onboardingBody3 => 'Zbieraj monety, odblokuj piętnaście wyjątkowych rowerów i ulepszaj każdą ich część.';

  @override
  String get onboardingTitle4 => 'Jedź po swojemu';

  @override
  String get onboardingBody4 => 'Ukończ setki misji albo jeźdź swobodnie przez niekończące się krajobrazy.';

  @override
  String get menuPlay => 'Graj';

  @override
  String get menuMissions => 'Misje';

  @override
  String get menuFreeRide => 'Wolna jazda';

  @override
  String get menuEndless => 'Ucieczka bez końca';

  @override
  String get menuGarage => 'Garaż';

  @override
  String get menuDaily => 'Nagrody dzienne';

  @override
  String get menuTasks => 'Zadania dnia';

  @override
  String get menuAchievements => 'Osiągnięcia';

  @override
  String get menuSettings => 'Ustawienia';

  @override
  String get menuBack => 'Wstecz';

  @override
  String get menuClose => 'Zamknij';

  @override
  String get menuConfirm => 'Potwierdź';

  @override
  String get menuCancel => 'Anuluj';

  @override
  String get menuContinue => 'Kontynuuj';

  @override
  String get currencyCoins => 'Monety';

  @override
  String get currencyGems => 'Klejnoty';

  @override
  String playerLevel(int level) {
    return 'Poziom $level';
  }

  @override
  String xpProgress(String current, String total) {
    return '$current / $total PD';
  }

  @override
  String bestDistance(String distance) {
    return 'Rekord: $distance';
  }

  @override
  String get rank1 => 'Żółtodziób';

  @override
  String get rank2 => 'Pedałowicz';

  @override
  String get rank3 => 'Uliczny jeździec';

  @override
  String get rank4 => 'Pionier szlaku';

  @override
  String get rank5 => 'Demon prędkości';

  @override
  String get rank6 => 'Łowca burz';

  @override
  String get rank7 => 'Kapitan szos';

  @override
  String get rank8 => 'Król gór';

  @override
  String get rank9 => 'Legenda';

  @override
  String get rank10 => 'Nieśmiertelny';

  @override
  String get world1 => 'Słoneczne łąki';

  @override
  String get world2 => 'Jesienny las';

  @override
  String get world3 => 'Czerwony kanion';

  @override
  String get world4 => 'Nadmorska szosa';

  @override
  String get world5 => 'Neonowe miasto';

  @override
  String get world6 => 'Lodowe szczyty';

  @override
  String get world7 => 'Szmaragdowa dżungla';

  @override
  String get world8 => 'Wiśniowa dolina';

  @override
  String get world9 => 'Rdzawe doki';

  @override
  String get world10 => 'Zaginiona świątynia';

  @override
  String get world11 => 'Przełęcz wulkanu';

  @override
  String get world12 => 'Gwiezdna autostrada';

  @override
  String get levelSelectTitle => 'Misje';

  @override
  String levelNumber(int number) {
    return 'Poziom $number';
  }

  @override
  String get levelLocked => 'Zablokowany';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zdobądź jeszcze $count gwiazdki, by odblokować',
      many: 'Zdobądź jeszcze $count gwiazdek, by odblokować',
      few: 'Zdobądź jeszcze $count gwiazdki, by odblokować',
      one: 'Zdobądź jeszcze $count gwiazdkę, by odblokować',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => 'Najpierw ukończ poprzedni poziom';

  @override
  String levelLength(String distance) {
    return 'Długość: $distance';
  }

  @override
  String get levelDifficulty => 'Trudność';

  @override
  String levelRecommendedPower(int power) {
    return 'Zalecana moc: $power';
  }

  @override
  String levelYourPower(int power) {
    return 'Twój rower: $power';
  }

  @override
  String get levelStart => 'Start';

  @override
  String get levelObjectives => 'Cele';

  @override
  String get objectiveFinish => 'Dotrzyj do mety';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zbierz $count monety',
      many: 'Zbierz $count monet',
      few: 'Zbierz $count monety',
      one: 'Zbierz $count monetę',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => 'Ukończ bez wywrotki';

  @override
  String objectiveTime(String time) {
    return 'Ukończ w czasie $time';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gwiazdki',
      many: '$count gwiazdek',
      few: '$count gwiazdki',
      one: '$count gwiazdka',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return 'Poziomy: $done / $total';
  }

  @override
  String get hudDistance => 'Dystans';

  @override
  String hudToGo(String distance) {
    return 'Zostało $distance';
  }

  @override
  String hudCombo(int multiplier) {
    return 'Kombo x$multiplier';
  }

  @override
  String get hudNearMiss => 'O włos!';

  @override
  String get hudPerfectJump => 'Idealny skok!';

  @override
  String get hudStormClose => 'Burza jest blisko!';

  @override
  String get hudGo => 'START!';

  @override
  String get hudSpeed => 'km/h';

  @override
  String get tutorialSwipeSides => 'Przesuń w lewo lub prawo, by zmienić pas';

  @override
  String get tutorialSwipeUp => 'Przesuń w górę, by skoczyć';

  @override
  String get tutorialSwipeDown => 'Przesuń w dół, by się schylić';

  @override
  String get tutorialCollect => 'Łap monety i bonusy!';

  @override
  String get powerMagnet => 'Magnes';

  @override
  String get powerShield => 'Tarcza';

  @override
  String get powerTurbo => 'Turbo';

  @override
  String get powerDoubleCoins => 'Monety x2';

  @override
  String get powerGhost => 'Duch';

  @override
  String get pauseTitle => 'Pauza';

  @override
  String get pauseResume => 'Wznów';

  @override
  String get pauseRestart => 'Od nowa';

  @override
  String get pauseQuit => 'Wyjdź do menu';

  @override
  String get crashTitle => 'Wywrotka!';

  @override
  String get crashCaught => 'Burza cię dopadła!';

  @override
  String get crashRevive => 'Wskrześ';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wskrześ za $count klejnotu',
      many: 'Wskrześ za $count klejnotów',
      few: 'Wskrześ za $count klejnoty',
      one: 'Wskrześ za $count klejnot',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'Poddaj się';

  @override
  String crashProgress(int percent) {
    return 'Pokonano $percent% trasy';
  }

  @override
  String get crashSoClose => 'Tak blisko! Jeszcze jedna próba?';

  @override
  String get resultLevelComplete => 'Poziom ukończony!';

  @override
  String get resultRunOver => 'Koniec jazdy';

  @override
  String get resultNewRecord => 'Nowy rekord!';

  @override
  String get resultDistance => 'Dystans';

  @override
  String get resultCoins => 'Monety';

  @override
  String get resultTime => 'Czas';

  @override
  String get resultXp => 'PD';

  @override
  String get resultNearMisses => 'Mijanki o włos';

  @override
  String get resultBestCombo => 'Najlepsze kombo';

  @override
  String get resultNextLevel => 'Dalej';

  @override
  String get resultRetry => 'Jeszcze raz';

  @override
  String get resultMenu => 'Menu';

  @override
  String resultLevelUp(int level) {
    return 'Awans! Masz teraz poziom $level';
  }

  @override
  String get resultBonusChest => 'Zdobyto skrzynię bonusową!';

  @override
  String get garageTitle => 'Garaż';

  @override
  String get garageBikes => 'Rowery';

  @override
  String get garageUpgrades => 'Ulepszenia';

  @override
  String get garagePaint => 'Lakier';

  @override
  String get garageBuy => 'Kup';

  @override
  String get garageSelect => 'Wybierz';

  @override
  String get garageSelected => 'W użyciu';

  @override
  String get garageOwned => 'Posiadany';

  @override
  String garageRequiresLevel(int level) {
    return 'Odblokowanie na poziomie $level';
  }

  @override
  String get garageNotEnough => 'Za mało monet';

  @override
  String get garageNotEnoughGems => 'Za mało klejnotów';

  @override
  String garagePower(int power) {
    return 'Moc $power';
  }

  @override
  String get garageUpgrade => 'Ulepsz';

  @override
  String get garageMaxed => 'Maks.';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Poz. $current/$max';
  }

  @override
  String get garagePurchased => 'Kupiono!';

  @override
  String get garageUpgraded => 'Ulepszono!';

  @override
  String get garageBuyBikeFirst => 'Kup ten rower, by go ulepszać';

  @override
  String get statTopSpeed => 'Prędkość maks.';

  @override
  String get statAcceleration => 'Przyspieszenie';

  @override
  String get statHandling => 'Sterowność';

  @override
  String get statJump => 'Skok';

  @override
  String get statDurability => 'Wytrzymałość';

  @override
  String get statLuck => 'Szczęście';

  @override
  String get bike1Name => 'Miejski Cruiser';

  @override
  String get bike1Desc => 'Wygodny stalowy klasyk. Wolny, ale wybaczający.';

  @override
  String get bike2Name => 'Ostre Koło';

  @override
  String get bike2Desc => 'Lekki ostrokołowiec do błyskawicznej zmiany pasa.';

  @override
  String get bike3Name => 'Łobuz BMX';

  @override
  String get bike3Desc => 'Małe koła, wielkie skoki. Stworzony do trików.';

  @override
  String get bike4Name => 'Górska Kozica';

  @override
  String get bike4Desc => 'Twardy góral, który nie boi się wybojów.';

  @override
  String get bike5Name => 'Szutrowy Nomada';

  @override
  String get bike5Desc => 'Zrównoważony rower na każdy rodzaj drogi.';

  @override
  String get bike6Name => 'Gruby Yeti';

  @override
  String get bike6Desc => 'Potężne opony, które śmieją się z wywrotek.';

  @override
  String get bike7Name => 'E-rower Volt';

  @override
  String get bike7Desc => 'Wspomaganie elektryczne dla zabójczego przyspieszenia.';

  @override
  String get bike8Name => 'Karbonowa Strzała';

  @override
  String get bike8Desc => 'Ultralekka szosówka o imponującej prędkości.';

  @override
  String get bike9Name => 'Bestia Downhill';

  @override
  String get bike9Desc => 'Pełne zawieszenie i nerwy ze stali.';

  @override
  String get bike10Name => 'Torowa Kometa';

  @override
  String get bike10Desc => 'Rakieta z welodromu. Mrugniesz i już jej nie ma.';

  @override
  String get bike11Name => 'Cień';

  @override
  String get bike11Desc => 'Matowa czarna rama przyciągająca szczęśliwe monety.';

  @override
  String get bike12Name => 'Tytan X';

  @override
  String get bike12Desc => 'Tytanowy pancerz na dwóch kołach.';

  @override
  String get bike13Name => 'Prototyp Aurora';

  @override
  String get bike13Desc => 'Eksperymentalna technologia i świecące koła.';

  @override
  String get bike14Name => 'Ognisty Feniks';

  @override
  String get bike14Desc => 'Zostawia ognisty ślad. Prawie nie do zatrzymania.';

  @override
  String get bike15Name => 'Niebiańska Legenda';

  @override
  String get bike15Desc => 'Rower ostateczny. Jeżdżą nim tylko prawdziwe legendy.';

  @override
  String get upgradeEngine => 'Przełożenie';

  @override
  String get upgradeEngineDesc => 'Zwiększa prędkość maksymalną.';

  @override
  String get upgradeChain => 'Łańcuch wyścigowy';

  @override
  String get upgradeChainDesc => 'Szybciej osiągasz pełną prędkość.';

  @override
  String get upgradeSteering => 'Kierownica';

  @override
  String get upgradeSteeringDesc => 'Szybciej zmieniasz pasy.';

  @override
  String get upgradeSuspension => 'Amortyzacja';

  @override
  String get upgradeSuspensionDesc => 'Skacz wyżej i ląduj miękciej.';

  @override
  String get upgradeFrame => 'Wzmocniona rama';

  @override
  String get upgradeFrameDesc => 'Wytrzymaj więcej uderzeń przed wywrotką.';

  @override
  String get upgradeTires => 'Przyczepne opony';

  @override
  String get upgradeTiresDesc => 'Mniej zwalniasz po potknięciu.';

  @override
  String get upgradeMagnet => 'Cewka magnesu';

  @override
  String get upgradeMagnetDesc => 'Bonus Magnes działa dłużej.';

  @override
  String get upgradeShield => 'Generator tarczy';

  @override
  String get upgradeShieldDesc => 'Bonus Tarcza działa dłużej.';

  @override
  String get upgradeTurbo => 'Dopalacz turbo';

  @override
  String get upgradeTurboDesc => 'Bonus Turbo działa dłużej.';

  @override
  String get upgradeCoinBag => 'Sakiewka';

  @override
  String get upgradeCoinBagDesc => 'Więcej monet z każdego zbioru.';

  @override
  String get upgradeLuck => 'Talizman';

  @override
  String get upgradeLuckDesc => 'Bonusy i klejnoty pojawiają się częściej.';

  @override
  String get upgradeLights => 'Reflektor';

  @override
  String get upgradeLightsDesc => 'Widzisz przeszkody z daleka nocą.';

  @override
  String get paintName1 => 'Fabryczny';

  @override
  String get paintName2 => 'Karmazyn';

  @override
  String get paintName3 => 'Ocean';

  @override
  String get paintName4 => 'Limonka';

  @override
  String get paintName5 => 'Zachód słońca';

  @override
  String get paintName6 => 'Północ';

  @override
  String get paintName7 => 'Złoto';

  @override
  String get paintName8 => 'Cukierek';

  @override
  String get dailyTitle => 'Nagrody dzienne';

  @override
  String dailyDay(int day) {
    return 'Dzień $day';
  }

  @override
  String get dailyClaim => 'Odbierz';

  @override
  String get dailyClaimed => 'Odebrano';

  @override
  String get dailyComeBack => 'Wróć jutro po większą nagrodę!';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seria: $count dnia',
      many: 'Seria: $count dni',
      few: 'Seria: $count dni',
      one: 'Seria: $count dzień',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => 'Nagroda czeka!';

  @override
  String dailyNextIn(String time) {
    return 'Następna nagroda za $time';
  }

  @override
  String get spinTitle => 'Koło fortuny';

  @override
  String get spinButton => 'Kręć!';

  @override
  String get spinFree => 'Darmowy obrót dostępny';

  @override
  String spinUsed(String time) {
    return 'Darmowy obrót za $time';
  }

  @override
  String spinWon(String reward) {
    return 'Wygrywasz: $reward!';
  }

  @override
  String get chestTitle => 'Tajemnicza skrzynia';

  @override
  String get chestOpen => 'Dotknij, by otworzyć';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skrzyni czeka',
      many: '$count skrzyń czeka',
      few: '$count skrzynie czekają',
      one: '$count skrzynia czeka',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'Zadania dnia';

  @override
  String tasksRefresh(String time) {
    return 'Nowe zadania za $time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zbierz $count monety',
      many: 'Zbierz $count monet',
      few: 'Zbierz $count monety',
      one: 'Zbierz $count monetę',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return 'Przejedź łącznie $distance';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przeskocz $count przeszkody',
      many: 'Przeskocz $count przeszkód',
      few: 'Przeskocz $count przeszkody',
      one: 'Przeskocz $count przeszkodę',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Schyl się pod $count przeszkody',
      many: 'Schyl się pod $count przeszkodami',
      few: 'Schyl się pod $count przeszkodami',
      one: 'Schyl się pod $count przeszkodą',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zalicz $count mijanki o włos',
      many: 'Zalicz $count mijanek o włos',
      few: 'Zalicz $count mijanki o włos',
      one: 'Zalicz $count mijankę o włos',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aktywuj $count bonusu',
      many: 'Aktywuj $count bonusów',
      few: 'Aktywuj $count bonusy',
      one: 'Aktywuj $count bonus',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ukończ $count poziomu',
      many: 'Ukończ $count poziomów',
      few: 'Ukończ $count poziomy',
      one: 'Ukończ $count poziom',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'Przejedź $distance w Wolnej jeździe';
  }

  @override
  String get taskClaim => 'Odbierz';

  @override
  String get taskDone => 'Gotowe';

  @override
  String get taskAllDone => 'Wszystkie zadania wykonane! Bonus odblokowany.';

  @override
  String get achievementsTitle => 'Osiągnięcia';

  @override
  String get achDistance => 'Długodystansowiec';

  @override
  String achDistanceDesc(String distance) {
    return 'Przejedź łącznie $distance';
  }

  @override
  String get achCoins => 'Łowca skarbów';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zbierz łącznie $count monety',
      many: 'Zbierz łącznie $count monet',
      few: 'Zbierz łącznie $count monety',
      one: 'Zbierz łącznie $count monetę',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'W powietrzu';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skocz $count razy',
      many: 'Skocz $count razy',
      few: 'Skocz $count razy',
      one: 'Skocz $count raz',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'Mistrz misji';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ukończ $count poziomu',
      many: 'Ukończ $count poziomów',
      few: 'Ukończ $count poziomy',
      one: 'Ukończ $count poziom',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'Zbieracz gwiazd';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zdobądź $count gwiazdki',
      many: 'Zdobądź $count gwiazdek',
      few: 'Zdobądź $count gwiazdki',
      one: 'Zdobądź $count gwiazdkę',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'Kolekcjoner';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Miej $count roweru',
      many: 'Miej $count rowerów',
      few: 'Miej $count rowery',
      one: 'Miej $count rower',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'Mechanik';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kup $count ulepszenia',
      many: 'Kup $count ulepszeń',
      few: 'Kup $count ulepszenia',
      one: 'Kup $count ulepszenie',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => 'Śmiałek';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zalicz $count mijanki o włos',
      many: 'Zalicz $count mijanek o włos',
      few: 'Zalicz $count mijanki o włos',
      one: 'Zalicz $count mijankę o włos',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => 'Wierny jeździec';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zaloguj się $count dnia z rzędu',
      many: 'Zaloguj się $count dni z rzędu',
      few: 'Zaloguj się $count dni z rzędu',
      one: 'Zaloguj się $count dzień z rzędu',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => 'Mistrz ucieczki';

  @override
  String achEndlessDesc(String distance) {
    return 'Osiągnij $distance w jednej Ucieczce bez końca';
  }

  @override
  String achTier(int tier) {
    return 'Stopień $tier';
  }

  @override
  String get achReward => 'Nagroda';

  @override
  String get achClaim => 'Odbierz';

  @override
  String get achCompleted => 'Ukończone';

  @override
  String get freeRideTitle => 'Wolna jazda';

  @override
  String get freeRideWorld => 'Świat';

  @override
  String get freeRideTime => 'Pora dnia';

  @override
  String get freeRideMorning => 'Rano';

  @override
  String get freeRideNoon => 'Południe';

  @override
  String get freeRideSunset => 'Zachód słońca';

  @override
  String get freeRideNight => 'Noc';

  @override
  String get freeRideCycle => 'Cykl dnia i nocy';

  @override
  String get freeRideWeather => 'Pogoda';

  @override
  String get weatherClear => 'Bezchmurnie';

  @override
  String get weatherRain => 'Deszcz';

  @override
  String get weatherSnow => 'Śnieg';

  @override
  String get weatherFog => 'Mgła';

  @override
  String get weatherLeaves => 'Spadające liście';

  @override
  String get freeRideTraffic => 'Ruch';

  @override
  String get freeRideTrafficNone => 'Brak';

  @override
  String get freeRideTrafficLight => 'Mały';

  @override
  String get freeRideTrafficHeavy => 'Duży';

  @override
  String get freeRideStart => 'Ruszaj';

  @override
  String get freeRideHint => 'Bez burzy, bez presji. Ciesz się jazdą i zbieraj monety po drodze.';

  @override
  String get freeRideLocked => 'Dotrzyj do tego świata w Misjach, by go odblokować';

  @override
  String get endlessTitle => 'Ucieczka bez końca';

  @override
  String get endlessHint => 'Jak daleko zajedziesz, zanim dopadnie cię burza?';

  @override
  String get endlessBest => 'Rekord osobisty';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSystem => 'Język telefonu';

  @override
  String get settingsSound => 'Efekty dźwiękowe';

  @override
  String get settingsMusic => 'Muzyka';

  @override
  String get settingsVibration => 'Wibracje';

  @override
  String get settingsGraphics => 'Jakość grafiki';

  @override
  String get graphicsLow => 'Niska';

  @override
  String get graphicsMedium => 'Średnia';

  @override
  String get graphicsHigh => 'Wysoka';

  @override
  String get settingsSensitivity => 'Czułość przesunięć';

  @override
  String get settingsShowTutorial => 'Pokaż samouczek ponownie';

  @override
  String get settingsReset => 'Resetuj postęp';

  @override
  String get settingsResetConfirm => 'To usunie wszystkie monety, rowery i poziomy. Na pewno?';

  @override
  String get settingsResetDone => 'Postęp zresetowany';

  @override
  String settingsVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get settingsOn => 'Wł.';

  @override
  String get settingsOff => 'Wył.';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count monety',
      many: '$count monet',
      few: '$count monety',
      one: '$count moneta',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count klejnotu',
      many: '$count klejnotów',
      few: '$count klejnoty',
      one: '$count klejnot',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'Tajemnicza skrzynia';

  @override
  String get rewardCollect => 'Odbierz';

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
    return '$hours godz. $minutes min';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'Witaj z powrotem, rowerzysto!';

  @override
  String offlineEarnings(String count) {
    return 'Gdy cię nie było, twoja ekipa znalazła monety: $count';
  }

  @override
  String get newBikeAvailable => 'W garażu czeka nowy rower!';

  @override
  String get almostThere => 'Prawie u celu!';

  @override
  String get keepGoing => 'Tak trzymaj!';

  @override
  String unlockedWorld(String world) {
    return 'Odblokowano nowy świat: $world';
  }
}
