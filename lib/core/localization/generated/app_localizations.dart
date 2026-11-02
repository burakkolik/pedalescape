import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('ja'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr')
  ];

  /// Full store/app title. MUST be 30 characters or fewer.
  ///
  /// In en, this message translates to:
  /// **'Pedal Escape: Bike Run'**
  String get appName;

  /// Short launcher label under the icon. Keep under 14 characters if possible.
  ///
  /// In en, this message translates to:
  /// **'Pedal Escape'**
  String get appShortName;

  /// Marketing tagline shown on splash and feature graphic.
  ///
  /// In en, this message translates to:
  /// **'Outrun the storm. Ride forever.'**
  String get appTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Pumping the tires...'**
  String get splashLoading;

  /// No description provided for @splashTip1.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to jump over low barriers.'**
  String get splashTip1;

  /// No description provided for @splashTip2.
  ///
  /// In en, this message translates to:
  /// **'Swipe down to duck under pipes and branches.'**
  String get splashTip2;

  /// No description provided for @splashTip3.
  ///
  /// In en, this message translates to:
  /// **'Near misses fill your combo meter faster.'**
  String get splashTip3;

  /// No description provided for @splashTip4.
  ///
  /// In en, this message translates to:
  /// **'Upgrades stay with each bike forever.'**
  String get splashTip4;

  /// No description provided for @splashTip5.
  ///
  /// In en, this message translates to:
  /// **'Come back every day — your streak rewards grow.'**
  String get splashTip5;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s ride!'**
  String get onboardingStart;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'The storm is coming'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'A wild storm is chasing you across twelve worlds. Pedal hard and never look back!'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Swipe to survive'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to switch lanes, up to jump, and down to duck.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Build your dream bike'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'Collect coins, unlock fifteen unique bikes and upgrade every part of them.'**
  String get onboardingBody3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Ride your way'**
  String get onboardingTitle4;

  /// No description provided for @onboardingBody4.
  ///
  /// In en, this message translates to:
  /// **'Finish hundreds of missions or cruise freely through endless scenery.'**
  String get onboardingBody4;

  /// No description provided for @menuPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get menuPlay;

  /// No description provided for @menuMissions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get menuMissions;

  /// No description provided for @menuFreeRide.
  ///
  /// In en, this message translates to:
  /// **'Free Ride'**
  String get menuFreeRide;

  /// No description provided for @menuEndless.
  ///
  /// In en, this message translates to:
  /// **'Endless Escape'**
  String get menuEndless;

  /// No description provided for @menuGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get menuGarage;

  /// No description provided for @menuDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Rewards'**
  String get menuDaily;

  /// No description provided for @menuTasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get menuTasks;

  /// No description provided for @menuAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get menuAchievements;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get menuBack;

  /// No description provided for @menuClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get menuClose;

  /// No description provided for @menuConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get menuConfirm;

  /// No description provided for @menuCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get menuCancel;

  /// No description provided for @menuContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get menuContinue;

  /// No description provided for @currencyCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get currencyCoins;

  /// No description provided for @currencyGems.
  ///
  /// In en, this message translates to:
  /// **'Gems'**
  String get currencyGems;

  /// No description provided for @playerLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String playerLevel(int level);

  /// No description provided for @xpProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total} XP'**
  String xpProgress(String current, String total);

  /// No description provided for @bestDistance.
  ///
  /// In en, this message translates to:
  /// **'Best: {distance}'**
  String bestDistance(String distance);

  /// No description provided for @rank1.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get rank1;

  /// No description provided for @rank2.
  ///
  /// In en, this message translates to:
  /// **'Pedal Pusher'**
  String get rank2;

  /// No description provided for @rank3.
  ///
  /// In en, this message translates to:
  /// **'Street Rider'**
  String get rank3;

  /// No description provided for @rank4.
  ///
  /// In en, this message translates to:
  /// **'Trail Blazer'**
  String get rank4;

  /// No description provided for @rank5.
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get rank5;

  /// No description provided for @rank6.
  ///
  /// In en, this message translates to:
  /// **'Storm Chaser'**
  String get rank6;

  /// No description provided for @rank7.
  ///
  /// In en, this message translates to:
  /// **'Road Captain'**
  String get rank7;

  /// No description provided for @rank8.
  ///
  /// In en, this message translates to:
  /// **'Mountain King'**
  String get rank8;

  /// No description provided for @rank9.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get rank9;

  /// No description provided for @rank10.
  ///
  /// In en, this message translates to:
  /// **'Pedal Immortal'**
  String get rank10;

  /// No description provided for @world1.
  ///
  /// In en, this message translates to:
  /// **'Sunny Meadows'**
  String get world1;

  /// No description provided for @world2.
  ///
  /// In en, this message translates to:
  /// **'Autumn Woods'**
  String get world2;

  /// No description provided for @world3.
  ///
  /// In en, this message translates to:
  /// **'Red Canyon'**
  String get world3;

  /// No description provided for @world4.
  ///
  /// In en, this message translates to:
  /// **'Coastal Highway'**
  String get world4;

  /// No description provided for @world5.
  ///
  /// In en, this message translates to:
  /// **'Neon City'**
  String get world5;

  /// No description provided for @world6.
  ///
  /// In en, this message translates to:
  /// **'Frozen Peaks'**
  String get world6;

  /// No description provided for @world7.
  ///
  /// In en, this message translates to:
  /// **'Emerald Jungle'**
  String get world7;

  /// No description provided for @world8.
  ///
  /// In en, this message translates to:
  /// **'Cherry Valley'**
  String get world8;

  /// No description provided for @world9.
  ///
  /// In en, this message translates to:
  /// **'Rusty Docks'**
  String get world9;

  /// No description provided for @world10.
  ///
  /// In en, this message translates to:
  /// **'Lost Temple'**
  String get world10;

  /// No description provided for @world11.
  ///
  /// In en, this message translates to:
  /// **'Volcano Pass'**
  String get world11;

  /// No description provided for @world12.
  ///
  /// In en, this message translates to:
  /// **'Starlight Highway'**
  String get world12;

  /// No description provided for @levelSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get levelSelectTitle;

  /// No description provided for @levelNumber.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String levelNumber(int number);

  /// No description provided for @levelLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get levelLocked;

  /// No description provided for @levelStarsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect 1 more star to unlock} other{Collect {count} more stars to unlock}}'**
  String levelStarsNeeded(int count);

  /// No description provided for @levelFinishPrevious.
  ///
  /// In en, this message translates to:
  /// **'Finish the previous level first'**
  String get levelFinishPrevious;

  /// No description provided for @levelLength.
  ///
  /// In en, this message translates to:
  /// **'Length: {distance}'**
  String levelLength(String distance);

  /// No description provided for @levelDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get levelDifficulty;

  /// No description provided for @levelRecommendedPower.
  ///
  /// In en, this message translates to:
  /// **'Recommended power: {power}'**
  String levelRecommendedPower(int power);

  /// No description provided for @levelYourPower.
  ///
  /// In en, this message translates to:
  /// **'Your bike: {power}'**
  String levelYourPower(int power);

  /// No description provided for @levelStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get levelStart;

  /// No description provided for @levelObjectives.
  ///
  /// In en, this message translates to:
  /// **'Objectives'**
  String get levelObjectives;

  /// No description provided for @objectiveFinish.
  ///
  /// In en, this message translates to:
  /// **'Reach the finish line'**
  String get objectiveFinish;

  /// No description provided for @objectiveCoins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect 1 coin} other{Collect {count} coins}}'**
  String objectiveCoins(int count);

  /// No description provided for @objectiveNoCrash.
  ///
  /// In en, this message translates to:
  /// **'Finish without crashing'**
  String get objectiveNoCrash;

  /// No description provided for @objectiveTime.
  ///
  /// In en, this message translates to:
  /// **'Finish within {time}'**
  String objectiveTime(String time);

  /// No description provided for @totalStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String totalStars(int count);

  /// No description provided for @worldProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} levels'**
  String worldProgress(int done, int total);

  /// No description provided for @hudDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get hudDistance;

  /// No description provided for @hudToGo.
  ///
  /// In en, this message translates to:
  /// **'{distance} to go'**
  String hudToGo(String distance);

  /// No description provided for @hudCombo.
  ///
  /// In en, this message translates to:
  /// **'Combo x{multiplier}'**
  String hudCombo(int multiplier);

  /// No description provided for @hudNearMiss.
  ///
  /// In en, this message translates to:
  /// **'Near miss!'**
  String get hudNearMiss;

  /// No description provided for @hudPerfectJump.
  ///
  /// In en, this message translates to:
  /// **'Perfect jump!'**
  String get hudPerfectJump;

  /// No description provided for @hudStormClose.
  ///
  /// In en, this message translates to:
  /// **'The storm is close!'**
  String get hudStormClose;

  /// No description provided for @hudGo.
  ///
  /// In en, this message translates to:
  /// **'GO!'**
  String get hudGo;

  /// No description provided for @hudSpeed.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get hudSpeed;

  /// No description provided for @tutorialSwipeSides.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to change lanes'**
  String get tutorialSwipeSides;

  /// No description provided for @tutorialSwipeUp.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to jump'**
  String get tutorialSwipeUp;

  /// No description provided for @tutorialSwipeDown.
  ///
  /// In en, this message translates to:
  /// **'Swipe down to duck'**
  String get tutorialSwipeDown;

  /// No description provided for @tutorialCollect.
  ///
  /// In en, this message translates to:
  /// **'Grab coins and power-ups!'**
  String get tutorialCollect;

  /// No description provided for @powerMagnet.
  ///
  /// In en, this message translates to:
  /// **'Magnet'**
  String get powerMagnet;

  /// No description provided for @powerShield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get powerShield;

  /// No description provided for @powerTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo'**
  String get powerTurbo;

  /// No description provided for @powerDoubleCoins.
  ///
  /// In en, this message translates to:
  /// **'Double Coins'**
  String get powerDoubleCoins;

  /// No description provided for @powerGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost Ride'**
  String get powerGhost;

  /// No description provided for @pauseTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pauseTitle;

  /// No description provided for @pauseResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pauseResume;

  /// No description provided for @pauseRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get pauseRestart;

  /// No description provided for @pauseQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit to Menu'**
  String get pauseQuit;

  /// No description provided for @crashTitle.
  ///
  /// In en, this message translates to:
  /// **'Wiped out!'**
  String get crashTitle;

  /// No description provided for @crashCaught.
  ///
  /// In en, this message translates to:
  /// **'The storm caught you!'**
  String get crashCaught;

  /// No description provided for @crashRevive.
  ///
  /// In en, this message translates to:
  /// **'Revive'**
  String get crashRevive;

  /// No description provided for @crashReviveCost.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Revive for 1 gem} other{Revive for {count} gems}}'**
  String crashReviveCost(int count);

  /// No description provided for @crashGiveUp.
  ///
  /// In en, this message translates to:
  /// **'Give up'**
  String get crashGiveUp;

  /// No description provided for @crashProgress.
  ///
  /// In en, this message translates to:
  /// **'You made it {percent}% of the way'**
  String crashProgress(int percent);

  /// No description provided for @crashSoClose.
  ///
  /// In en, this message translates to:
  /// **'So close! Just one more try?'**
  String get crashSoClose;

  /// No description provided for @resultLevelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get resultLevelComplete;

  /// No description provided for @resultRunOver.
  ///
  /// In en, this message translates to:
  /// **'Run Over'**
  String get resultRunOver;

  /// No description provided for @resultNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New record!'**
  String get resultNewRecord;

  /// No description provided for @resultDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get resultDistance;

  /// No description provided for @resultCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get resultCoins;

  /// No description provided for @resultTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get resultTime;

  /// No description provided for @resultXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get resultXp;

  /// No description provided for @resultNearMisses.
  ///
  /// In en, this message translates to:
  /// **'Near misses'**
  String get resultNearMisses;

  /// No description provided for @resultBestCombo.
  ///
  /// In en, this message translates to:
  /// **'Best combo'**
  String get resultBestCombo;

  /// No description provided for @resultNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get resultNextLevel;

  /// No description provided for @resultRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get resultRetry;

  /// No description provided for @resultMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get resultMenu;

  /// No description provided for @resultLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up! You are now level {level}'**
  String resultLevelUp(int level);

  /// No description provided for @resultBonusChest.
  ///
  /// In en, this message translates to:
  /// **'Bonus chest earned!'**
  String get resultBonusChest;

  /// No description provided for @garageTitle.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garageTitle;

  /// No description provided for @garageBikes.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get garageBikes;

  /// No description provided for @garageUpgrades.
  ///
  /// In en, this message translates to:
  /// **'Upgrades'**
  String get garageUpgrades;

  /// No description provided for @garagePaint.
  ///
  /// In en, this message translates to:
  /// **'Paint'**
  String get garagePaint;

  /// No description provided for @garageBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get garageBuy;

  /// No description provided for @garageSelect.
  ///
  /// In en, this message translates to:
  /// **'Ride this'**
  String get garageSelect;

  /// No description provided for @garageSelected.
  ///
  /// In en, this message translates to:
  /// **'Riding'**
  String get garageSelected;

  /// No description provided for @garageOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get garageOwned;

  /// No description provided for @garageRequiresLevel.
  ///
  /// In en, this message translates to:
  /// **'Unlocks at level {level}'**
  String garageRequiresLevel(int level);

  /// No description provided for @garageNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get garageNotEnough;

  /// No description provided for @garageNotEnoughGems.
  ///
  /// In en, this message translates to:
  /// **'Not enough gems'**
  String get garageNotEnoughGems;

  /// No description provided for @garagePower.
  ///
  /// In en, this message translates to:
  /// **'Power {power}'**
  String garagePower(int power);

  /// No description provided for @garageUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get garageUpgrade;

  /// No description provided for @garageMaxed.
  ///
  /// In en, this message translates to:
  /// **'Maxed'**
  String get garageMaxed;

  /// No description provided for @garageUpgradeLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv {current}/{max}'**
  String garageUpgradeLevel(int current, int max);

  /// No description provided for @garagePurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased!'**
  String get garagePurchased;

  /// No description provided for @garageUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Upgraded!'**
  String get garageUpgraded;

  /// No description provided for @garageBuyBikeFirst.
  ///
  /// In en, this message translates to:
  /// **'Buy this bike to upgrade it'**
  String get garageBuyBikeFirst;

  /// No description provided for @statTopSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get statTopSpeed;

  /// No description provided for @statAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Acceleration'**
  String get statAcceleration;

  /// No description provided for @statHandling.
  ///
  /// In en, this message translates to:
  /// **'Handling'**
  String get statHandling;

  /// No description provided for @statJump.
  ///
  /// In en, this message translates to:
  /// **'Jump'**
  String get statJump;

  /// No description provided for @statDurability.
  ///
  /// In en, this message translates to:
  /// **'Durability'**
  String get statDurability;

  /// No description provided for @statLuck.
  ///
  /// In en, this message translates to:
  /// **'Luck'**
  String get statLuck;

  /// No description provided for @bike1Name.
  ///
  /// In en, this message translates to:
  /// **'City Cruiser'**
  String get bike1Name;

  /// No description provided for @bike1Desc.
  ///
  /// In en, this message translates to:
  /// **'A comfy steel classic. Slow but forgiving.'**
  String get bike1Desc;

  /// No description provided for @bike2Name.
  ///
  /// In en, this message translates to:
  /// **'Fixie Flash'**
  String get bike2Name;

  /// No description provided for @bike2Desc.
  ///
  /// In en, this message translates to:
  /// **'Light single-speed built for quick lane changes.'**
  String get bike2Desc;

  /// No description provided for @bike3Name.
  ///
  /// In en, this message translates to:
  /// **'BMX Rascal'**
  String get bike3Name;

  /// No description provided for @bike3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tiny wheels, huge jumps. Born for tricks.'**
  String get bike3Desc;

  /// No description provided for @bike4Name.
  ///
  /// In en, this message translates to:
  /// **'Trail Goat'**
  String get bike4Name;

  /// No description provided for @bike4Desc.
  ///
  /// In en, this message translates to:
  /// **'A tough mountain bike that shrugs off bumps.'**
  String get bike4Desc;

  /// No description provided for @bike5Name.
  ///
  /// In en, this message translates to:
  /// **'Gravel Nomad'**
  String get bike5Name;

  /// No description provided for @bike5Desc.
  ///
  /// In en, this message translates to:
  /// **'Balanced all-rounder for every kind of road.'**
  String get bike5Desc;

  /// No description provided for @bike6Name.
  ///
  /// In en, this message translates to:
  /// **'Fat Yeti'**
  String get bike6Name;

  /// No description provided for @bike6Desc.
  ///
  /// In en, this message translates to:
  /// **'Monster tires that laugh at crashes.'**
  String get bike6Desc;

  /// No description provided for @bike7Name.
  ///
  /// In en, this message translates to:
  /// **'Volt E-Bike'**
  String get bike7Name;

  /// No description provided for @bike7Desc.
  ///
  /// In en, this message translates to:
  /// **'Electric assist for blistering acceleration.'**
  String get bike7Desc;

  /// No description provided for @bike8Name.
  ///
  /// In en, this message translates to:
  /// **'Carbon Arrow'**
  String get bike8Name;

  /// No description provided for @bike8Desc.
  ///
  /// In en, this message translates to:
  /// **'Featherweight road racer with serious top speed.'**
  String get bike8Desc;

  /// No description provided for @bike9Name.
  ///
  /// In en, this message translates to:
  /// **'Downhill Beast'**
  String get bike9Name;

  /// No description provided for @bike9Desc.
  ///
  /// In en, this message translates to:
  /// **'Full suspension and nerves of steel.'**
  String get bike9Desc;

  /// No description provided for @bike10Name.
  ///
  /// In en, this message translates to:
  /// **'Track Comet'**
  String get bike10Name;

  /// No description provided for @bike10Desc.
  ///
  /// In en, this message translates to:
  /// **'A velodrome rocket. Blink and you miss it.'**
  String get bike10Desc;

  /// No description provided for @bike11Name.
  ///
  /// In en, this message translates to:
  /// **'Shadow Stealth'**
  String get bike11Name;

  /// No description provided for @bike11Desc.
  ///
  /// In en, this message translates to:
  /// **'Matte black frame that attracts lucky coins.'**
  String get bike11Desc;

  /// No description provided for @bike12Name.
  ///
  /// In en, this message translates to:
  /// **'Titan X'**
  String get bike12Name;

  /// No description provided for @bike12Desc.
  ///
  /// In en, this message translates to:
  /// **'Titanium armor on two wheels.'**
  String get bike12Desc;

  /// No description provided for @bike13Name.
  ///
  /// In en, this message translates to:
  /// **'Aurora Prototype'**
  String get bike13Name;

  /// No description provided for @bike13Desc.
  ///
  /// In en, this message translates to:
  /// **'Experimental tech with glowing wheels.'**
  String get bike13Desc;

  /// No description provided for @bike14Name.
  ///
  /// In en, this message translates to:
  /// **'Phoenix Blaze'**
  String get bike14Name;

  /// No description provided for @bike14Desc.
  ///
  /// In en, this message translates to:
  /// **'Leaves a trail of fire. Nearly unstoppable.'**
  String get bike14Desc;

  /// No description provided for @bike15Name.
  ///
  /// In en, this message translates to:
  /// **'Celestial Legend'**
  String get bike15Name;

  /// No description provided for @bike15Desc.
  ///
  /// In en, this message translates to:
  /// **'The ultimate bike. Only true legends ride it.'**
  String get bike15Desc;

  /// No description provided for @upgradeEngine.
  ///
  /// In en, this message translates to:
  /// **'Gear Ratio'**
  String get upgradeEngine;

  /// No description provided for @upgradeEngineDesc.
  ///
  /// In en, this message translates to:
  /// **'Raises your top speed.'**
  String get upgradeEngineDesc;

  /// No description provided for @upgradeChain.
  ///
  /// In en, this message translates to:
  /// **'Racing Chain'**
  String get upgradeChain;

  /// No description provided for @upgradeChainDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach full speed faster.'**
  String get upgradeChainDesc;

  /// No description provided for @upgradeSteering.
  ///
  /// In en, this message translates to:
  /// **'Steering'**
  String get upgradeSteering;

  /// No description provided for @upgradeSteeringDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch lanes more quickly.'**
  String get upgradeSteeringDesc;

  /// No description provided for @upgradeSuspension.
  ///
  /// In en, this message translates to:
  /// **'Suspension'**
  String get upgradeSuspension;

  /// No description provided for @upgradeSuspensionDesc.
  ///
  /// In en, this message translates to:
  /// **'Jump higher and land softer.'**
  String get upgradeSuspensionDesc;

  /// No description provided for @upgradeFrame.
  ///
  /// In en, this message translates to:
  /// **'Reinforced Frame'**
  String get upgradeFrame;

  /// No description provided for @upgradeFrameDesc.
  ///
  /// In en, this message translates to:
  /// **'Survive more hits before wiping out.'**
  String get upgradeFrameDesc;

  /// No description provided for @upgradeTires.
  ///
  /// In en, this message translates to:
  /// **'Grip Tires'**
  String get upgradeTires;

  /// No description provided for @upgradeTiresDesc.
  ///
  /// In en, this message translates to:
  /// **'Less slowdown when you stumble.'**
  String get upgradeTiresDesc;

  /// No description provided for @upgradeMagnet.
  ///
  /// In en, this message translates to:
  /// **'Magnet Coil'**
  String get upgradeMagnet;

  /// No description provided for @upgradeMagnetDesc.
  ///
  /// In en, this message translates to:
  /// **'Magnet power-up lasts longer.'**
  String get upgradeMagnetDesc;

  /// No description provided for @upgradeShield.
  ///
  /// In en, this message translates to:
  /// **'Shield Generator'**
  String get upgradeShield;

  /// No description provided for @upgradeShieldDesc.
  ///
  /// In en, this message translates to:
  /// **'Shield power-up lasts longer.'**
  String get upgradeShieldDesc;

  /// No description provided for @upgradeTurbo.
  ///
  /// In en, this message translates to:
  /// **'Turbo Booster'**
  String get upgradeTurbo;

  /// No description provided for @upgradeTurboDesc.
  ///
  /// In en, this message translates to:
  /// **'Turbo power-up lasts longer.'**
  String get upgradeTurboDesc;

  /// No description provided for @upgradeCoinBag.
  ///
  /// In en, this message translates to:
  /// **'Coin Pouch'**
  String get upgradeCoinBag;

  /// No description provided for @upgradeCoinBagDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn more coins from every pickup.'**
  String get upgradeCoinBagDesc;

  /// No description provided for @upgradeLuck.
  ///
  /// In en, this message translates to:
  /// **'Lucky Charm'**
  String get upgradeLuck;

  /// No description provided for @upgradeLuckDesc.
  ///
  /// In en, this message translates to:
  /// **'Power-ups and gems appear more often.'**
  String get upgradeLuckDesc;

  /// No description provided for @upgradeLights.
  ///
  /// In en, this message translates to:
  /// **'Headlight'**
  String get upgradeLights;

  /// No description provided for @upgradeLightsDesc.
  ///
  /// In en, this message translates to:
  /// **'See obstacles from farther away at night.'**
  String get upgradeLightsDesc;

  /// No description provided for @paintName1.
  ///
  /// In en, this message translates to:
  /// **'Factory'**
  String get paintName1;

  /// No description provided for @paintName2.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get paintName2;

  /// No description provided for @paintName3.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get paintName3;

  /// No description provided for @paintName4.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get paintName4;

  /// No description provided for @paintName5.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get paintName5;

  /// No description provided for @paintName6.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get paintName6;

  /// No description provided for @paintName7.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get paintName7;

  /// No description provided for @paintName8.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get paintName8;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Rewards'**
  String get dailyTitle;

  /// No description provided for @dailyDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dailyDay(int day);

  /// No description provided for @dailyClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get dailyClaim;

  /// No description provided for @dailyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get dailyClaimed;

  /// No description provided for @dailyComeBack.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for a bigger reward!'**
  String get dailyComeBack;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1-day streak} other{{count}-day streak}}'**
  String dailyStreak(int count);

  /// No description provided for @dailyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Reward ready!'**
  String get dailyAvailable;

  /// No description provided for @dailyNextIn.
  ///
  /// In en, this message translates to:
  /// **'Next reward in {time}'**
  String dailyNextIn(String time);

  /// No description provided for @spinTitle.
  ///
  /// In en, this message translates to:
  /// **'Lucky Wheel'**
  String get spinTitle;

  /// No description provided for @spinButton.
  ///
  /// In en, this message translates to:
  /// **'Spin!'**
  String get spinButton;

  /// No description provided for @spinFree.
  ///
  /// In en, this message translates to:
  /// **'Free spin available'**
  String get spinFree;

  /// No description provided for @spinUsed.
  ///
  /// In en, this message translates to:
  /// **'Next free spin in {time}'**
  String spinUsed(String time);

  /// No description provided for @spinWon.
  ///
  /// In en, this message translates to:
  /// **'You won {reward}!'**
  String spinWon(String reward);

  /// No description provided for @chestTitle.
  ///
  /// In en, this message translates to:
  /// **'Mystery Chest'**
  String get chestTitle;

  /// No description provided for @chestOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open'**
  String get chestOpen;

  /// No description provided for @chestCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chest waiting} other{{count} chests waiting}}'**
  String chestCount(int count);

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksRefresh.
  ///
  /// In en, this message translates to:
  /// **'New tasks in {time}'**
  String tasksRefresh(String time);

  /// No description provided for @taskCollectCoins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect 1 coin} other{Collect {count} coins}}'**
  String taskCollectCoins(int count);

  /// No description provided for @taskRideDistance.
  ///
  /// In en, this message translates to:
  /// **'Ride {distance} in total'**
  String taskRideDistance(String distance);

  /// No description provided for @taskJump.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Jump over 1 obstacle} other{Jump over {count} obstacles}}'**
  String taskJump(int count);

  /// No description provided for @taskDuck.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Duck under 1 obstacle} other{Duck under {count} obstacles}}'**
  String taskDuck(int count);

  /// No description provided for @taskNearMiss.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Make 1 near miss} other{Make {count} near misses}}'**
  String taskNearMiss(int count);

  /// No description provided for @taskPowerUps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Use 1 power-up} other{Use {count} power-ups}}'**
  String taskPowerUps(int count);

  /// No description provided for @taskLevels.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Complete 1 level} other{Complete {count} levels}}'**
  String taskLevels(int count);

  /// No description provided for @taskFreeRide.
  ///
  /// In en, this message translates to:
  /// **'Cruise {distance} in Free Ride'**
  String taskFreeRide(String distance);

  /// No description provided for @taskClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get taskClaim;

  /// No description provided for @taskDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskDone;

  /// No description provided for @taskAllDone.
  ///
  /// In en, this message translates to:
  /// **'All tasks complete! Bonus unlocked.'**
  String get taskAllDone;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achDistance.
  ///
  /// In en, this message translates to:
  /// **'Long Hauler'**
  String get achDistance;

  /// No description provided for @achDistanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Ride {distance} in total'**
  String achDistanceDesc(String distance);

  /// No description provided for @achCoins.
  ///
  /// In en, this message translates to:
  /// **'Treasure Hunter'**
  String get achCoins;

  /// No description provided for @achCoinsDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Collect 1 coin in total} other{Collect {count} coins in total}}'**
  String achCoinsDesc(int count);

  /// No description provided for @achJumps.
  ///
  /// In en, this message translates to:
  /// **'Air Time'**
  String get achJumps;

  /// No description provided for @achJumpsDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Jump 1 time} other{Jump {count} times}}'**
  String achJumpsDesc(int count);

  /// No description provided for @achLevels.
  ///
  /// In en, this message translates to:
  /// **'Mission Master'**
  String get achLevels;

  /// No description provided for @achLevelsDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Complete 1 level} other{Complete {count} levels}}'**
  String achLevelsDesc(int count);

  /// No description provided for @achStars.
  ///
  /// In en, this message translates to:
  /// **'Star Collector'**
  String get achStars;

  /// No description provided for @achStarsDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Earn 1 star} other{Earn {count} stars}}'**
  String achStarsDesc(int count);

  /// No description provided for @achBikes.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achBikes;

  /// No description provided for @achBikesDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Own 1 bike} other{Own {count} bikes}}'**
  String achBikesDesc(int count);

  /// No description provided for @achUpgrades.
  ///
  /// In en, this message translates to:
  /// **'Mechanic'**
  String get achUpgrades;

  /// No description provided for @achUpgradesDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Buy 1 upgrade} other{Buy {count} upgrades}}'**
  String achUpgradesDesc(int count);

  /// No description provided for @achNearMiss.
  ///
  /// In en, this message translates to:
  /// **'Daredevil'**
  String get achNearMiss;

  /// No description provided for @achNearMissDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Make 1 near miss} other{Make {count} near misses}}'**
  String achNearMissDesc(int count);

  /// No description provided for @achStreak.
  ///
  /// In en, this message translates to:
  /// **'Loyal Rider'**
  String get achStreak;

  /// No description provided for @achStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Log in 1 day in a row} other{Log in {count} days in a row}}'**
  String achStreakDesc(int count);

  /// No description provided for @achEndless.
  ///
  /// In en, this message translates to:
  /// **'Escape Artist'**
  String get achEndless;

  /// No description provided for @achEndlessDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach {distance} in one Endless run'**
  String achEndlessDesc(String distance);

  /// No description provided for @achTier.
  ///
  /// In en, this message translates to:
  /// **'Tier {tier}'**
  String achTier(int tier);

  /// No description provided for @achReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get achReward;

  /// No description provided for @achClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get achClaim;

  /// No description provided for @achCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get achCompleted;

  /// No description provided for @freeRideTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Ride'**
  String get freeRideTitle;

  /// No description provided for @freeRideWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get freeRideWorld;

  /// No description provided for @freeRideTime.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get freeRideTime;

  /// No description provided for @freeRideMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get freeRideMorning;

  /// No description provided for @freeRideNoon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get freeRideNoon;

  /// No description provided for @freeRideSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get freeRideSunset;

  /// No description provided for @freeRideNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get freeRideNight;

  /// No description provided for @freeRideCycle.
  ///
  /// In en, this message translates to:
  /// **'Day & night cycle'**
  String get freeRideCycle;

  /// No description provided for @freeRideWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get freeRideWeather;

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherFog;

  /// No description provided for @weatherLeaves.
  ///
  /// In en, this message translates to:
  /// **'Falling leaves'**
  String get weatherLeaves;

  /// No description provided for @freeRideTraffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get freeRideTraffic;

  /// No description provided for @freeRideTrafficNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get freeRideTrafficNone;

  /// No description provided for @freeRideTrafficLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get freeRideTrafficLight;

  /// No description provided for @freeRideTrafficHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get freeRideTrafficHeavy;

  /// No description provided for @freeRideStart.
  ///
  /// In en, this message translates to:
  /// **'Start cruising'**
  String get freeRideStart;

  /// No description provided for @freeRideHint.
  ///
  /// In en, this message translates to:
  /// **'No storm, no pressure. Enjoy the ride and pick up coins along the way.'**
  String get freeRideHint;

  /// No description provided for @freeRideLocked.
  ///
  /// In en, this message translates to:
  /// **'Reach this world in Missions to unlock it'**
  String get freeRideLocked;

  /// No description provided for @endlessTitle.
  ///
  /// In en, this message translates to:
  /// **'Endless Escape'**
  String get endlessTitle;

  /// No description provided for @endlessHint.
  ///
  /// In en, this message translates to:
  /// **'How far can you go before the storm catches you?'**
  String get endlessHint;

  /// No description provided for @endlessBest.
  ///
  /// In en, this message translates to:
  /// **'Personal best'**
  String get endlessBest;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSound;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsGraphics.
  ///
  /// In en, this message translates to:
  /// **'Graphics quality'**
  String get settingsGraphics;

  /// No description provided for @graphicsLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get graphicsLow;

  /// No description provided for @graphicsMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get graphicsMedium;

  /// No description provided for @graphicsHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get graphicsHigh;

  /// No description provided for @settingsSensitivity.
  ///
  /// In en, this message translates to:
  /// **'Swipe sensitivity'**
  String get settingsSensitivity;

  /// No description provided for @settingsShowTutorial.
  ///
  /// In en, this message translates to:
  /// **'Show tutorial again'**
  String get settingsShowTutorial;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsReset;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'This deletes all coins, bikes and levels. Are you sure?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Progress reset'**
  String get settingsResetDone;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @rewardCoins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coin} other{{count} coins}}'**
  String rewardCoins(int count);

  /// No description provided for @rewardGems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 gem} other{{count} gems}}'**
  String rewardGems(int count);

  /// No description provided for @rewardChest.
  ///
  /// In en, this message translates to:
  /// **'Mystery chest'**
  String get rewardChest;

  /// No description provided for @rewardCollect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get rewardCollect;

  /// No description provided for @distanceMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String distanceMeters(String value);

  /// No description provided for @distanceKilometers.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKilometers(String value);

  /// No description provided for @timeHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String timeHoursMinutes(int hours, int minutes);

  /// No description provided for @timeMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}:{seconds}'**
  String timeMinutesSeconds(String minutes, String seconds);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, rider!'**
  String get welcomeBack;

  /// No description provided for @offlineEarnings.
  ///
  /// In en, this message translates to:
  /// **'Your bike crew found {count} coins while you were away'**
  String offlineEarnings(String count);

  /// No description provided for @newBikeAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new bike is waiting in the garage!'**
  String get newBikeAvailable;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// No description provided for @unlockedWorld.
  ///
  /// In en, this message translates to:
  /// **'New world unlocked: {world}'**
  String unlockedWorld(String world);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id', 'ja', 'pl', 'pt', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
    case 'ja': return AppLocalizationsJa();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
