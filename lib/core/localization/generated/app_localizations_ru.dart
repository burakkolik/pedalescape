// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Pedal Escape: Велопобег';

  @override
  String get appShortName => 'Pedal Escape';

  @override
  String get appTagline => 'Уйди от бури. Крути педали вечно.';

  @override
  String get splashLoading => 'Накачиваем шины...';

  @override
  String get splashTip1 => 'Свайп вверх — прыжок через низкие барьеры.';

  @override
  String get splashTip2 => 'Свайп вниз — пригнуться под трубами и ветками.';

  @override
  String get splashTip3 => 'Опасные сближения быстрее заполняют шкалу комбо.';

  @override
  String get splashTip4 => 'Улучшения навсегда остаются на каждом велосипеде.';

  @override
  String get splashTip5 => 'Заходи каждый день — награды за серию растут.';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Погнали!';

  @override
  String get onboardingTitle1 => 'Надвигается буря';

  @override
  String get onboardingBody1 => 'Дикая буря гонится за тобой через двенадцать миров. Жми на педали и не оглядывайся!';

  @override
  String get onboardingTitle2 => 'Свайпай, чтобы выжить';

  @override
  String get onboardingBody2 => 'Свайп влево или вправо — смена полосы, вверх — прыжок, вниз — пригнуться.';

  @override
  String get onboardingTitle3 => 'Собери байк мечты';

  @override
  String get onboardingBody3 => 'Собирай монеты, открой пятнадцать уникальных велосипедов и улучшай каждую деталь.';

  @override
  String get onboardingTitle4 => 'Катайся как хочешь';

  @override
  String get onboardingBody4 => 'Проходи сотни миссий или свободно катайся среди бесконечных пейзажей.';

  @override
  String get menuPlay => 'Играть';

  @override
  String get menuMissions => 'Миссии';

  @override
  String get menuFreeRide => 'Свободная езда';

  @override
  String get menuEndless => 'Бесконечный побег';

  @override
  String get menuGarage => 'Гараж';

  @override
  String get menuDaily => 'Ежедневные награды';

  @override
  String get menuTasks => 'Задания дня';

  @override
  String get menuAchievements => 'Достижения';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuBack => 'Назад';

  @override
  String get menuClose => 'Закрыть';

  @override
  String get menuConfirm => 'Подтвердить';

  @override
  String get menuCancel => 'Отмена';

  @override
  String get menuContinue => 'Продолжить';

  @override
  String get currencyCoins => 'Монеты';

  @override
  String get currencyGems => 'Кристаллы';

  @override
  String playerLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String xpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String bestDistance(String distance) {
    return 'Рекорд: $distance';
  }

  @override
  String get rank1 => 'Новичок';

  @override
  String get rank2 => 'Педальщик';

  @override
  String get rank3 => 'Уличный райдер';

  @override
  String get rank4 => 'Первопроходец';

  @override
  String get rank5 => 'Демон скорости';

  @override
  String get rank6 => 'Охотник за бурей';

  @override
  String get rank7 => 'Капитан дорог';

  @override
  String get rank8 => 'Король гор';

  @override
  String get rank9 => 'Легенда';

  @override
  String get rank10 => 'Бессмертный';

  @override
  String get world1 => 'Солнечные луга';

  @override
  String get world2 => 'Осенний лес';

  @override
  String get world3 => 'Красный каньон';

  @override
  String get world4 => 'Прибрежное шоссе';

  @override
  String get world5 => 'Неоновый город';

  @override
  String get world6 => 'Ледяные пики';

  @override
  String get world7 => 'Изумрудные джунгли';

  @override
  String get world8 => 'Вишнёвая долина';

  @override
  String get world9 => 'Ржавые доки';

  @override
  String get world10 => 'Затерянный храм';

  @override
  String get world11 => 'Перевал вулкана';

  @override
  String get world12 => 'Звёздное шоссе';

  @override
  String get levelSelectTitle => 'Миссии';

  @override
  String levelNumber(int number) {
    return 'Уровень $number';
  }

  @override
  String get levelLocked => 'Закрыто';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Собери ещё $count звезды, чтобы открыть',
      many: 'Собери ещё $count звёзд, чтобы открыть',
      few: 'Собери ещё $count звезды, чтобы открыть',
      one: 'Собери ещё $count звезду, чтобы открыть',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => 'Сначала пройди предыдущий уровень';

  @override
  String levelLength(String distance) {
    return 'Длина: $distance';
  }

  @override
  String get levelDifficulty => 'Сложность';

  @override
  String levelRecommendedPower(int power) {
    return 'Рекомендуемая мощь: $power';
  }

  @override
  String levelYourPower(int power) {
    return 'Твой байк: $power';
  }

  @override
  String get levelStart => 'Старт';

  @override
  String get levelObjectives => 'Цели';

  @override
  String get objectiveFinish => 'Доберись до финиша';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Собери $count монеты',
      many: 'Собери $count монет',
      few: 'Собери $count монеты',
      one: 'Собери $count монету',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => 'Финишируй без аварий';

  @override
  String objectiveTime(String time) {
    return 'Уложись в $time';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count звезды',
      many: '$count звёзд',
      few: '$count звезды',
      one: '$count звезда',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return 'Уровни: $done / $total';
  }

  @override
  String get hudDistance => 'Дистанция';

  @override
  String hudToGo(String distance) {
    return 'Осталось $distance';
  }

  @override
  String hudCombo(int multiplier) {
    return 'Комбо x$multiplier';
  }

  @override
  String get hudNearMiss => 'На волоске!';

  @override
  String get hudPerfectJump => 'Идеальный прыжок!';

  @override
  String get hudStormClose => 'Буря совсем близко!';

  @override
  String get hudGo => 'ВПЕРЁД!';

  @override
  String get hudSpeed => 'км/ч';

  @override
  String get tutorialSwipeSides => 'Свайп влево или вправо — смена полосы';

  @override
  String get tutorialSwipeUp => 'Свайп вверх — прыжок';

  @override
  String get tutorialSwipeDown => 'Свайп вниз — пригнуться';

  @override
  String get tutorialCollect => 'Хватай монеты и бонусы!';

  @override
  String get powerMagnet => 'Магнит';

  @override
  String get powerShield => 'Щит';

  @override
  String get powerTurbo => 'Турбо';

  @override
  String get powerDoubleCoins => 'Монеты x2';

  @override
  String get powerGhost => 'Призрак';

  @override
  String get pauseTitle => 'Пауза';

  @override
  String get pauseResume => 'Продолжить';

  @override
  String get pauseRestart => 'Заново';

  @override
  String get pauseQuit => 'Выйти в меню';

  @override
  String get crashTitle => 'Авария!';

  @override
  String get crashCaught => 'Буря тебя настигла!';

  @override
  String get crashRevive => 'Воскреснуть';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Воскреснуть за $count кристалла',
      many: 'Воскреснуть за $count кристаллов',
      few: 'Воскреснуть за $count кристалла',
      one: 'Воскреснуть за $count кристалл',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'Сдаться';

  @override
  String crashProgress(int percent) {
    return 'Пройдено $percent% пути';
  }

  @override
  String get crashSoClose => 'Почти получилось! Ещё разок?';

  @override
  String get resultLevelComplete => 'Уровень пройден!';

  @override
  String get resultRunOver => 'Заезд окончен';

  @override
  String get resultNewRecord => 'Новый рекорд!';

  @override
  String get resultDistance => 'Дистанция';

  @override
  String get resultCoins => 'Монеты';

  @override
  String get resultTime => 'Время';

  @override
  String get resultXp => 'XP';

  @override
  String get resultNearMisses => 'На волоске';

  @override
  String get resultBestCombo => 'Лучшее комбо';

  @override
  String get resultNextLevel => 'Следующий';

  @override
  String get resultRetry => 'Ещё раз';

  @override
  String get resultMenu => 'Меню';

  @override
  String resultLevelUp(int level) {
    return 'Новый уровень! Теперь у тебя уровень $level';
  }

  @override
  String get resultBonusChest => 'Получен бонусный сундук!';

  @override
  String get garageTitle => 'Гараж';

  @override
  String get garageBikes => 'Байки';

  @override
  String get garageUpgrades => 'Улучшения';

  @override
  String get garagePaint => 'Окраска';

  @override
  String get garageBuy => 'Купить';

  @override
  String get garageSelect => 'Выбрать';

  @override
  String get garageSelected => 'Выбран';

  @override
  String get garageOwned => 'Куплен';

  @override
  String garageRequiresLevel(int level) {
    return 'Откроется на уровне $level';
  }

  @override
  String get garageNotEnough => 'Не хватает монет';

  @override
  String get garageNotEnoughGems => 'Не хватает кристаллов';

  @override
  String garagePower(int power) {
    return 'Мощь $power';
  }

  @override
  String get garageUpgrade => 'Улучшить';

  @override
  String get garageMaxed => 'Максимум';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Ур. $current/$max';
  }

  @override
  String get garagePurchased => 'Куплено!';

  @override
  String get garageUpgraded => 'Улучшено!';

  @override
  String get garageBuyBikeFirst => 'Купи этот байк, чтобы улучшать его';

  @override
  String get statTopSpeed => 'Макс. скорость';

  @override
  String get statAcceleration => 'Разгон';

  @override
  String get statHandling => 'Управление';

  @override
  String get statJump => 'Прыжок';

  @override
  String get statDurability => 'Прочность';

  @override
  String get statLuck => 'Удача';

  @override
  String get bike1Name => 'Сити-круизер';

  @override
  String get bike1Desc => 'Удобная стальная классика. Медленный, но прощает ошибки.';

  @override
  String get bike2Name => 'Фикс-Молния';

  @override
  String get bike2Desc => 'Лёгкий синглспид для быстрой смены полос.';

  @override
  String get bike3Name => 'BMX-Хулиган';

  @override
  String get bike3Desc => 'Маленькие колёса, огромные прыжки. Создан для трюков.';

  @override
  String get bike4Name => 'Горный козёл';

  @override
  String get bike4Desc => 'Крепкий горный байк, которому кочки нипочём.';

  @override
  String get bike5Name => 'Кочевник';

  @override
  String get bike5Desc => 'Сбалансированный универсал для любых дорог.';

  @override
  String get bike6Name => 'Толстый йети';

  @override
  String get bike6Desc => 'Монструозные шины, которым смешны аварии.';

  @override
  String get bike7Name => 'Электро Вольт';

  @override
  String get bike7Desc => 'Электропривод для бешеного разгона.';

  @override
  String get bike8Name => 'Карбоновая стрела';

  @override
  String get bike8Desc => 'Сверхлёгкий шоссейник с серьёзной макс. скоростью.';

  @override
  String get bike9Name => 'Даунхилл-Зверь';

  @override
  String get bike9Desc => 'Полная подвеска и стальные нервы.';

  @override
  String get bike10Name => 'Трековая комета';

  @override
  String get bike10Desc => 'Ракета велотрека. Моргнёшь — и не увидишь.';

  @override
  String get bike11Name => 'Тёмная тень';

  @override
  String get bike11Desc => 'Матово-чёрная рама, притягивающая счастливые монеты.';

  @override
  String get bike12Name => 'Титан X';

  @override
  String get bike12Desc => 'Титановая броня на двух колёсах.';

  @override
  String get bike13Name => 'Прототип «Аврора»';

  @override
  String get bike13Desc => 'Экспериментальные технологии и светящиеся колёса.';

  @override
  String get bike14Name => 'Пламя Феникса';

  @override
  String get bike14Desc => 'Оставляет огненный след. Почти неудержим.';

  @override
  String get bike15Name => 'Небесная легенда';

  @override
  String get bike15Desc => 'Лучший байк. Только для настоящих легенд.';

  @override
  String get upgradeEngine => 'Передачи';

  @override
  String get upgradeEngineDesc => 'Повышает максимальную скорость.';

  @override
  String get upgradeChain => 'Гоночная цепь';

  @override
  String get upgradeChainDesc => 'Быстрее набирай полную скорость.';

  @override
  String get upgradeSteering => 'Руль';

  @override
  String get upgradeSteeringDesc => 'Быстрее меняй полосы.';

  @override
  String get upgradeSuspension => 'Подвеска';

  @override
  String get upgradeSuspensionDesc => 'Прыгай выше и приземляйся мягче.';

  @override
  String get upgradeFrame => 'Усиленная рама';

  @override
  String get upgradeFrameDesc => 'Выдерживай больше ударов до аварии.';

  @override
  String get upgradeTires => 'Цепкие шины';

  @override
  String get upgradeTiresDesc => 'Меньше теряешь скорость при запинке.';

  @override
  String get upgradeMagnet => 'Электромагнит';

  @override
  String get upgradeMagnetDesc => 'Бонус «Магнит» действует дольше.';

  @override
  String get upgradeShield => 'Генератор щита';

  @override
  String get upgradeShieldDesc => 'Бонус «Щит» действует дольше.';

  @override
  String get upgradeTurbo => 'Турбоускоритель';

  @override
  String get upgradeTurboDesc => 'Бонус «Турбо» действует дольше.';

  @override
  String get upgradeCoinBag => 'Кошелёк';

  @override
  String get upgradeCoinBagDesc => 'Больше монет с каждой находки.';

  @override
  String get upgradeLuck => 'Талисман удачи';

  @override
  String get upgradeLuckDesc => 'Бонусы и кристаллы появляются чаще.';

  @override
  String get upgradeLights => 'Фара';

  @override
  String get upgradeLightsDesc => 'Видь препятствия ночью издалека.';

  @override
  String get paintName1 => 'Заводской';

  @override
  String get paintName2 => 'Багровый';

  @override
  String get paintName3 => 'Океан';

  @override
  String get paintName4 => 'Лайм';

  @override
  String get paintName5 => 'Закат';

  @override
  String get paintName6 => 'Полночь';

  @override
  String get paintName7 => 'Золото';

  @override
  String get paintName8 => 'Карамель';

  @override
  String get dailyTitle => 'Ежедневные награды';

  @override
  String dailyDay(int day) {
    return 'День $day';
  }

  @override
  String get dailyClaim => 'Забрать';

  @override
  String get dailyClaimed => 'Получено';

  @override
  String get dailyComeBack => 'Возвращайся завтра за наградой побольше!';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Серия: $count дня',
      many: 'Серия: $count дней',
      few: 'Серия: $count дня',
      one: 'Серия: $count день',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => 'Награда готова!';

  @override
  String dailyNextIn(String time) {
    return 'Следующая награда через $time';
  }

  @override
  String get spinTitle => 'Колесо удачи';

  @override
  String get spinButton => 'Крутить!';

  @override
  String get spinFree => 'Доступно бесплатное вращение';

  @override
  String spinUsed(String time) {
    return 'Бесплатное вращение через $time';
  }

  @override
  String spinWon(String reward) {
    return 'Твой выигрыш: $reward!';
  }

  @override
  String get chestTitle => 'Тайный сундук';

  @override
  String get chestOpen => 'Нажми, чтобы открыть';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сундука ждут',
      many: '$count сундуков ждут',
      few: '$count сундука ждут',
      one: '$count сундук ждёт',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'Задания дня';

  @override
  String tasksRefresh(String time) {
    return 'Новые задания через $time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Собрать $count монеты',
      many: 'Собрать $count монет',
      few: 'Собрать $count монеты',
      one: 'Собрать $count монету',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return 'Проехать всего $distance';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перепрыгнуть $count препятствия',
      many: 'Перепрыгнуть $count препятствий',
      few: 'Перепрыгнуть $count препятствия',
      one: 'Перепрыгнуть $count препятствие',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пригнуться под $count препятствиями',
      many: 'Пригнуться под $count препятствиями',
      few: 'Пригнуться под $count препятствиями',
      one: 'Пригнуться под $count препятствием',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пронестись на волоске $count раза',
      many: 'Пронестись на волоске $count раз',
      few: 'Пронестись на волоске $count раза',
      one: 'Пронестись на волоске $count раз',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Использовать $count бонуса',
      many: 'Использовать $count бонусов',
      few: 'Использовать $count бонуса',
      one: 'Использовать $count бонус',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пройти $count уровня',
      many: 'Пройти $count уровней',
      few: 'Пройти $count уровня',
      one: 'Пройти $count уровень',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'Проехать $distance в свободной езде';
  }

  @override
  String get taskClaim => 'Забрать';

  @override
  String get taskDone => 'Готово';

  @override
  String get taskAllDone => 'Все задания выполнены! Бонус открыт.';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String get achDistance => 'Дальнобойщик';

  @override
  String achDistanceDesc(String distance) {
    return 'Проехать всего $distance';
  }

  @override
  String get achCoins => 'Кладоискатель';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Собрать всего $count монеты',
      many: 'Собрать всего $count монет',
      few: 'Собрать всего $count монеты',
      one: 'Собрать всего $count монету',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'В полёте';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Прыгнуть $count раза',
      many: 'Прыгнуть $count раз',
      few: 'Прыгнуть $count раза',
      one: 'Прыгнуть $count раз',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'Мастер миссий';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пройти $count уровня',
      many: 'Пройти $count уровней',
      few: 'Пройти $count уровня',
      one: 'Пройти $count уровень',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'Звездочёт';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Заработать $count звезды',
      many: 'Заработать $count звёзд',
      few: 'Заработать $count звезды',
      one: 'Заработать $count звезду',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'Коллекционер';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Владеть $count байка',
      many: 'Владеть $count байками',
      few: 'Владеть $count байками',
      one: 'Владеть $count байком',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'Механик';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Купить $count улучшения',
      many: 'Купить $count улучшений',
      few: 'Купить $count улучшения',
      one: 'Купить $count улучшение',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => 'Сорвиголова';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Пронестись на волоске $count раза',
      many: 'Пронестись на волоске $count раз',
      few: 'Пронестись на волоске $count раза',
      one: 'Пронестись на волоске $count раз',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => 'Верный райдер';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Заходить $count дня подряд',
      many: 'Заходить $count дней подряд',
      few: 'Заходить $count дня подряд',
      one: 'Заходить $count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => 'Мастер побега';

  @override
  String achEndlessDesc(String distance) {
    return 'Проехать $distance за один бесконечный заезд';
  }

  @override
  String achTier(int tier) {
    return 'Ступень $tier';
  }

  @override
  String get achReward => 'Награда';

  @override
  String get achClaim => 'Забрать';

  @override
  String get achCompleted => 'Выполнено';

  @override
  String get freeRideTitle => 'Свободная езда';

  @override
  String get freeRideWorld => 'Мир';

  @override
  String get freeRideTime => 'Время суток';

  @override
  String get freeRideMorning => 'Утро';

  @override
  String get freeRideNoon => 'Полдень';

  @override
  String get freeRideSunset => 'Закат';

  @override
  String get freeRideNight => 'Ночь';

  @override
  String get freeRideCycle => 'Смена дня и ночи';

  @override
  String get freeRideWeather => 'Погода';

  @override
  String get weatherClear => 'Ясно';

  @override
  String get weatherRain => 'Дождь';

  @override
  String get weatherSnow => 'Снег';

  @override
  String get weatherFog => 'Туман';

  @override
  String get weatherLeaves => 'Листопад';

  @override
  String get freeRideTraffic => 'Трафик';

  @override
  String get freeRideTrafficNone => 'Нет';

  @override
  String get freeRideTrafficLight => 'Слабый';

  @override
  String get freeRideTrafficHeavy => 'Плотный';

  @override
  String get freeRideStart => 'Поехали';

  @override
  String get freeRideHint => 'Ни бури, ни спешки. Наслаждайся поездкой и собирай монеты по пути.';

  @override
  String get freeRideLocked => 'Дойди до этого мира в миссиях, чтобы открыть его';

  @override
  String get endlessTitle => 'Бесконечный побег';

  @override
  String get endlessHint => 'Как далеко ты уедешь, прежде чем буря тебя настигнет?';

  @override
  String get endlessBest => 'Личный рекорд';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Язык телефона';

  @override
  String get settingsSound => 'Звуковые эффекты';

  @override
  String get settingsMusic => 'Музыка';

  @override
  String get settingsVibration => 'Вибрация';

  @override
  String get settingsGraphics => 'Качество графики';

  @override
  String get graphicsLow => 'Низкое';

  @override
  String get graphicsMedium => 'Среднее';

  @override
  String get graphicsHigh => 'Высокое';

  @override
  String get settingsSensitivity => 'Чувствительность свайпа';

  @override
  String get settingsShowTutorial => 'Показать обучение снова';

  @override
  String get settingsReset => 'Сбросить прогресс';

  @override
  String get settingsResetConfirm => 'Все монеты, байки и уровни будут удалены. Ты уверен?';

  @override
  String get settingsResetDone => 'Прогресс сброшен';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsOn => 'Вкл.';

  @override
  String get settingsOff => 'Выкл.';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count монеты',
      many: '$count монет',
      few: '$count монеты',
      one: '$count монета',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кристалла',
      many: '$count кристаллов',
      few: '$count кристалла',
      one: '$count кристалл',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'Тайный сундук';

  @override
  String get rewardCollect => 'Забрать';

  @override
  String distanceMeters(String value) {
    return '$value м';
  }

  @override
  String distanceKilometers(String value) {
    return '$value км';
  }

  @override
  String timeHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'С возвращением, райдер!';

  @override
  String offlineEarnings(String count) {
    return 'Пока тебя не было, твоя команда нашла монеты: $count';
  }

  @override
  String get newBikeAvailable => 'В гараже тебя ждёт новый байк!';

  @override
  String get almostThere => 'Почти у цели!';

  @override
  String get keepGoing => 'Не сбавляй темп!';

  @override
  String unlockedWorld(String world) {
    return 'Открыт новый мир: $world';
  }
}
