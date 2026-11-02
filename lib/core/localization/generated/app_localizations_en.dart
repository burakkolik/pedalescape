// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pedal Escape: Bike Run';

  @override
  String get appShortName => 'Pedal Escape';

  @override
  String get appTagline => 'Outrun the storm. Ride forever.';

  @override
  String get splashLoading => 'Pumping the tires...';

  @override
  String get splashTip1 => 'Swipe up to jump over low barriers.';

  @override
  String get splashTip2 => 'Swipe down to duck under pipes and branches.';

  @override
  String get splashTip3 => 'Near misses fill your combo meter faster.';

  @override
  String get splashTip4 => 'Upgrades stay with each bike forever.';

  @override
  String get splashTip5 => 'Come back every day — your streak rewards grow.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Let\'s ride!';

  @override
  String get onboardingTitle1 => 'The storm is coming';

  @override
  String get onboardingBody1 => 'A wild storm is chasing you across twelve worlds. Pedal hard and never look back!';

  @override
  String get onboardingTitle2 => 'Swipe to survive';

  @override
  String get onboardingBody2 => 'Swipe left or right to switch lanes, up to jump, and down to duck.';

  @override
  String get onboardingTitle3 => 'Build your dream bike';

  @override
  String get onboardingBody3 => 'Collect coins, unlock fifteen unique bikes and upgrade every part of them.';

  @override
  String get onboardingTitle4 => 'Ride your way';

  @override
  String get onboardingBody4 => 'Finish hundreds of missions or cruise freely through endless scenery.';

  @override
  String get menuPlay => 'Play';

  @override
  String get menuMissions => 'Missions';

  @override
  String get menuFreeRide => 'Free Ride';

  @override
  String get menuEndless => 'Endless Escape';

  @override
  String get menuGarage => 'Garage';

  @override
  String get menuDaily => 'Daily Rewards';

  @override
  String get menuTasks => 'Daily Tasks';

  @override
  String get menuAchievements => 'Achievements';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuBack => 'Back';

  @override
  String get menuClose => 'Close';

  @override
  String get menuConfirm => 'Confirm';

  @override
  String get menuCancel => 'Cancel';

  @override
  String get menuContinue => 'Continue';

  @override
  String get currencyCoins => 'Coins';

  @override
  String get currencyGems => 'Gems';

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
    return 'Best: $distance';
  }

  @override
  String get rank1 => 'Rookie';

  @override
  String get rank2 => 'Pedal Pusher';

  @override
  String get rank3 => 'Street Rider';

  @override
  String get rank4 => 'Trail Blazer';

  @override
  String get rank5 => 'Speed Demon';

  @override
  String get rank6 => 'Storm Chaser';

  @override
  String get rank7 => 'Road Captain';

  @override
  String get rank8 => 'Mountain King';

  @override
  String get rank9 => 'Legend';

  @override
  String get rank10 => 'Pedal Immortal';

  @override
  String get world1 => 'Sunny Meadows';

  @override
  String get world2 => 'Autumn Woods';

  @override
  String get world3 => 'Red Canyon';

  @override
  String get world4 => 'Coastal Highway';

  @override
  String get world5 => 'Neon City';

  @override
  String get world6 => 'Frozen Peaks';

  @override
  String get world7 => 'Emerald Jungle';

  @override
  String get world8 => 'Cherry Valley';

  @override
  String get world9 => 'Rusty Docks';

  @override
  String get world10 => 'Lost Temple';

  @override
  String get world11 => 'Volcano Pass';

  @override
  String get world12 => 'Starlight Highway';

  @override
  String get levelSelectTitle => 'Missions';

  @override
  String levelNumber(int number) {
    return 'Level $number';
  }

  @override
  String get levelLocked => 'Locked';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count more stars to unlock',
      one: 'Collect 1 more star to unlock',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => 'Finish the previous level first';

  @override
  String levelLength(String distance) {
    return 'Length: $distance';
  }

  @override
  String get levelDifficulty => 'Difficulty';

  @override
  String levelRecommendedPower(int power) {
    return 'Recommended power: $power';
  }

  @override
  String levelYourPower(int power) {
    return 'Your bike: $power';
  }

  @override
  String get levelStart => 'Start';

  @override
  String get levelObjectives => 'Objectives';

  @override
  String get objectiveFinish => 'Reach the finish line';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count coins',
      one: 'Collect 1 coin',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => 'Finish without crashing';

  @override
  String objectiveTime(String time) {
    return 'Finish within $time';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return '$done / $total levels';
  }

  @override
  String get hudDistance => 'Distance';

  @override
  String hudToGo(String distance) {
    return '$distance to go';
  }

  @override
  String hudCombo(int multiplier) {
    return 'Combo x$multiplier';
  }

  @override
  String get hudNearMiss => 'Near miss!';

  @override
  String get hudPerfectJump => 'Perfect jump!';

  @override
  String get hudStormClose => 'The storm is close!';

  @override
  String get hudGo => 'GO!';

  @override
  String get hudSpeed => 'km/h';

  @override
  String get tutorialSwipeSides => 'Swipe left or right to change lanes';

  @override
  String get tutorialSwipeUp => 'Swipe up to jump';

  @override
  String get tutorialSwipeDown => 'Swipe down to duck';

  @override
  String get tutorialCollect => 'Grab coins and power-ups!';

  @override
  String get powerMagnet => 'Magnet';

  @override
  String get powerShield => 'Shield';

  @override
  String get powerTurbo => 'Turbo';

  @override
  String get powerDoubleCoins => 'Double Coins';

  @override
  String get powerGhost => 'Ghost Ride';

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseResume => 'Resume';

  @override
  String get pauseRestart => 'Restart';

  @override
  String get pauseQuit => 'Quit to Menu';

  @override
  String get crashTitle => 'Wiped out!';

  @override
  String get crashCaught => 'The storm caught you!';

  @override
  String get crashRevive => 'Revive';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Revive for $count gems',
      one: 'Revive for 1 gem',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'Give up';

  @override
  String crashProgress(int percent) {
    return 'You made it $percent% of the way';
  }

  @override
  String get crashSoClose => 'So close! Just one more try?';

  @override
  String get resultLevelComplete => 'Level Complete!';

  @override
  String get resultRunOver => 'Run Over';

  @override
  String get resultNewRecord => 'New record!';

  @override
  String get resultDistance => 'Distance';

  @override
  String get resultCoins => 'Coins';

  @override
  String get resultTime => 'Time';

  @override
  String get resultXp => 'XP';

  @override
  String get resultNearMisses => 'Near misses';

  @override
  String get resultBestCombo => 'Best combo';

  @override
  String get resultNextLevel => 'Next Level';

  @override
  String get resultRetry => 'Retry';

  @override
  String get resultMenu => 'Menu';

  @override
  String resultLevelUp(int level) {
    return 'Level up! You are now level $level';
  }

  @override
  String get resultBonusChest => 'Bonus chest earned!';

  @override
  String get garageTitle => 'Garage';

  @override
  String get garageBikes => 'Bikes';

  @override
  String get garageUpgrades => 'Upgrades';

  @override
  String get garagePaint => 'Paint';

  @override
  String get garageBuy => 'Buy';

  @override
  String get garageSelect => 'Ride this';

  @override
  String get garageSelected => 'Riding';

  @override
  String get garageOwned => 'Owned';

  @override
  String garageRequiresLevel(int level) {
    return 'Unlocks at level $level';
  }

  @override
  String get garageNotEnough => 'Not enough coins';

  @override
  String get garageNotEnoughGems => 'Not enough gems';

  @override
  String garagePower(int power) {
    return 'Power $power';
  }

  @override
  String get garageUpgrade => 'Upgrade';

  @override
  String get garageMaxed => 'Maxed';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Lv $current/$max';
  }

  @override
  String get garagePurchased => 'Purchased!';

  @override
  String get garageUpgraded => 'Upgraded!';

  @override
  String get garageBuyBikeFirst => 'Buy this bike to upgrade it';

  @override
  String get statTopSpeed => 'Top speed';

  @override
  String get statAcceleration => 'Acceleration';

  @override
  String get statHandling => 'Handling';

  @override
  String get statJump => 'Jump';

  @override
  String get statDurability => 'Durability';

  @override
  String get statLuck => 'Luck';

  @override
  String get bike1Name => 'City Cruiser';

  @override
  String get bike1Desc => 'A comfy steel classic. Slow but forgiving.';

  @override
  String get bike2Name => 'Fixie Flash';

  @override
  String get bike2Desc => 'Light single-speed built for quick lane changes.';

  @override
  String get bike3Name => 'BMX Rascal';

  @override
  String get bike3Desc => 'Tiny wheels, huge jumps. Born for tricks.';

  @override
  String get bike4Name => 'Trail Goat';

  @override
  String get bike4Desc => 'A tough mountain bike that shrugs off bumps.';

  @override
  String get bike5Name => 'Gravel Nomad';

  @override
  String get bike5Desc => 'Balanced all-rounder for every kind of road.';

  @override
  String get bike6Name => 'Fat Yeti';

  @override
  String get bike6Desc => 'Monster tires that laugh at crashes.';

  @override
  String get bike7Name => 'Volt E-Bike';

  @override
  String get bike7Desc => 'Electric assist for blistering acceleration.';

  @override
  String get bike8Name => 'Carbon Arrow';

  @override
  String get bike8Desc => 'Featherweight road racer with serious top speed.';

  @override
  String get bike9Name => 'Downhill Beast';

  @override
  String get bike9Desc => 'Full suspension and nerves of steel.';

  @override
  String get bike10Name => 'Track Comet';

  @override
  String get bike10Desc => 'A velodrome rocket. Blink and you miss it.';

  @override
  String get bike11Name => 'Shadow Stealth';

  @override
  String get bike11Desc => 'Matte black frame that attracts lucky coins.';

  @override
  String get bike12Name => 'Titan X';

  @override
  String get bike12Desc => 'Titanium armor on two wheels.';

  @override
  String get bike13Name => 'Aurora Prototype';

  @override
  String get bike13Desc => 'Experimental tech with glowing wheels.';

  @override
  String get bike14Name => 'Phoenix Blaze';

  @override
  String get bike14Desc => 'Leaves a trail of fire. Nearly unstoppable.';

  @override
  String get bike15Name => 'Celestial Legend';

  @override
  String get bike15Desc => 'The ultimate bike. Only true legends ride it.';

  @override
  String get upgradeEngine => 'Gear Ratio';

  @override
  String get upgradeEngineDesc => 'Raises your top speed.';

  @override
  String get upgradeChain => 'Racing Chain';

  @override
  String get upgradeChainDesc => 'Reach full speed faster.';

  @override
  String get upgradeSteering => 'Steering';

  @override
  String get upgradeSteeringDesc => 'Switch lanes more quickly.';

  @override
  String get upgradeSuspension => 'Suspension';

  @override
  String get upgradeSuspensionDesc => 'Jump higher and land softer.';

  @override
  String get upgradeFrame => 'Reinforced Frame';

  @override
  String get upgradeFrameDesc => 'Survive more hits before wiping out.';

  @override
  String get upgradeTires => 'Grip Tires';

  @override
  String get upgradeTiresDesc => 'Less slowdown when you stumble.';

  @override
  String get upgradeMagnet => 'Magnet Coil';

  @override
  String get upgradeMagnetDesc => 'Magnet power-up lasts longer.';

  @override
  String get upgradeShield => 'Shield Generator';

  @override
  String get upgradeShieldDesc => 'Shield power-up lasts longer.';

  @override
  String get upgradeTurbo => 'Turbo Booster';

  @override
  String get upgradeTurboDesc => 'Turbo power-up lasts longer.';

  @override
  String get upgradeCoinBag => 'Coin Pouch';

  @override
  String get upgradeCoinBagDesc => 'Earn more coins from every pickup.';

  @override
  String get upgradeLuck => 'Lucky Charm';

  @override
  String get upgradeLuckDesc => 'Power-ups and gems appear more often.';

  @override
  String get upgradeLights => 'Headlight';

  @override
  String get upgradeLightsDesc => 'See obstacles from farther away at night.';

  @override
  String get paintName1 => 'Factory';

  @override
  String get paintName2 => 'Crimson';

  @override
  String get paintName3 => 'Ocean';

  @override
  String get paintName4 => 'Lime';

  @override
  String get paintName5 => 'Sunset';

  @override
  String get paintName6 => 'Midnight';

  @override
  String get paintName7 => 'Gold';

  @override
  String get paintName8 => 'Candy';

  @override
  String get dailyTitle => 'Daily Rewards';

  @override
  String dailyDay(int day) {
    return 'Day $day';
  }

  @override
  String get dailyClaim => 'Claim';

  @override
  String get dailyClaimed => 'Claimed';

  @override
  String get dailyComeBack => 'Come back tomorrow for a bigger reward!';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => 'Reward ready!';

  @override
  String dailyNextIn(String time) {
    return 'Next reward in $time';
  }

  @override
  String get spinTitle => 'Lucky Wheel';

  @override
  String get spinButton => 'Spin!';

  @override
  String get spinFree => 'Free spin available';

  @override
  String spinUsed(String time) {
    return 'Next free spin in $time';
  }

  @override
  String spinWon(String reward) {
    return 'You won $reward!';
  }

  @override
  String get chestTitle => 'Mystery Chest';

  @override
  String get chestOpen => 'Tap to open';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chests waiting',
      one: '1 chest waiting',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'Daily Tasks';

  @override
  String tasksRefresh(String time) {
    return 'New tasks in $time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count coins',
      one: 'Collect 1 coin',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return 'Ride $distance in total';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jump over $count obstacles',
      one: 'Jump over 1 obstacle',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Duck under $count obstacles',
      one: 'Duck under 1 obstacle',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Make $count near misses',
      one: 'Make 1 near miss',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Use $count power-ups',
      one: 'Use 1 power-up',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Complete $count levels',
      one: 'Complete 1 level',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'Cruise $distance in Free Ride';
  }

  @override
  String get taskClaim => 'Claim';

  @override
  String get taskDone => 'Done';

  @override
  String get taskAllDone => 'All tasks complete! Bonus unlocked.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achDistance => 'Long Hauler';

  @override
  String achDistanceDesc(String distance) {
    return 'Ride $distance in total';
  }

  @override
  String get achCoins => 'Treasure Hunter';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Collect $count coins in total',
      one: 'Collect 1 coin in total',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'Air Time';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jump $count times',
      one: 'Jump 1 time',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'Mission Master';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Complete $count levels',
      one: 'Complete 1 level',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'Star Collector';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Earn $count stars',
      one: 'Earn 1 star',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'Collector';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Own $count bikes',
      one: 'Own 1 bike',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'Mechanic';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buy $count upgrades',
      one: 'Buy 1 upgrade',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => 'Daredevil';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Make $count near misses',
      one: 'Make 1 near miss',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => 'Loyal Rider';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Log in $count days in a row',
      one: 'Log in 1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => 'Escape Artist';

  @override
  String achEndlessDesc(String distance) {
    return 'Reach $distance in one Endless run';
  }

  @override
  String achTier(int tier) {
    return 'Tier $tier';
  }

  @override
  String get achReward => 'Reward';

  @override
  String get achClaim => 'Claim';

  @override
  String get achCompleted => 'Completed';

  @override
  String get freeRideTitle => 'Free Ride';

  @override
  String get freeRideWorld => 'World';

  @override
  String get freeRideTime => 'Time of day';

  @override
  String get freeRideMorning => 'Morning';

  @override
  String get freeRideNoon => 'Noon';

  @override
  String get freeRideSunset => 'Sunset';

  @override
  String get freeRideNight => 'Night';

  @override
  String get freeRideCycle => 'Day & night cycle';

  @override
  String get freeRideWeather => 'Weather';

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherFog => 'Fog';

  @override
  String get weatherLeaves => 'Falling leaves';

  @override
  String get freeRideTraffic => 'Traffic';

  @override
  String get freeRideTrafficNone => 'None';

  @override
  String get freeRideTrafficLight => 'Light';

  @override
  String get freeRideTrafficHeavy => 'Heavy';

  @override
  String get freeRideStart => 'Start cruising';

  @override
  String get freeRideHint => 'No storm, no pressure. Enjoy the ride and pick up coins along the way.';

  @override
  String get freeRideLocked => 'Reach this world in Missions to unlock it';

  @override
  String get endlessTitle => 'Endless Escape';

  @override
  String get endlessHint => 'How far can you go before the storm catches you?';

  @override
  String get endlessBest => 'Personal best';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone language';

  @override
  String get settingsSound => 'Sound effects';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsGraphics => 'Graphics quality';

  @override
  String get graphicsLow => 'Low';

  @override
  String get graphicsMedium => 'Medium';

  @override
  String get graphicsHigh => 'High';

  @override
  String get settingsSensitivity => 'Swipe sensitivity';

  @override
  String get settingsShowTutorial => 'Show tutorial again';

  @override
  String get settingsReset => 'Reset progress';

  @override
  String get settingsResetConfirm => 'This deletes all coins, bikes and levels. Are you sure?';

  @override
  String get settingsResetDone => 'Progress reset';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsOn => 'On';

  @override
  String get settingsOff => 'Off';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins',
      one: '1 coin',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gems',
      one: '1 gem',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'Mystery chest';

  @override
  String get rewardCollect => 'Collect';

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
    return '${hours}h ${minutes}m';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'Welcome back, rider!';

  @override
  String offlineEarnings(String count) {
    return 'Your bike crew found $count coins while you were away';
  }

  @override
  String get newBikeAvailable => 'A new bike is waiting in the garage!';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get keepGoing => 'Keep going!';

  @override
  String unlockedWorld(String world) {
    return 'New world unlocked: $world';
  }
}
