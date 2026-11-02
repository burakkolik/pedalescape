// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ペダルエスケープ：嵐から逃げろ！';

  @override
  String get appShortName => 'ペダルエスケープ';

  @override
  String get appTagline => '嵐を振り切れ。どこまでも走れ。';

  @override
  String get splashLoading => 'タイヤに空気を入れています…';

  @override
  String get splashTip1 => '上スワイプで低い障害物を飛び越えよう！';

  @override
  String get splashTip2 => '下スワイプでパイプや枝の下をくぐり抜けよう。';

  @override
  String get splashTip3 => 'ニアミスを決めるとコンボゲージが早くたまる！';

  @override
  String get splashTip4 => '強化は自転車ごとにずっと残るよ。';

  @override
  String get splashTip5 => '毎日ログインで連続ボーナスがどんどん豪華に！';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingStart => 'さあ、出発！';

  @override
  String get onboardingTitle1 => '嵐がやってくる';

  @override
  String get onboardingBody1 => '荒れ狂う嵐が12のワールドを越えて追いかけてくる。全力でペダルをこいで、振り返らずに走り抜けよう！';

  @override
  String get onboardingTitle2 => 'スワイプで生き残れ';

  @override
  String get onboardingBody2 => '左右スワイプでレーン移動、上でジャンプ、下でしゃがもう。';

  @override
  String get onboardingTitle3 => '夢の自転車を作ろう';

  @override
  String get onboardingBody3 => 'コインを集めて15台の個性的な自転車を解放し、すべてのパーツを強化しよう。';

  @override
  String get onboardingTitle4 => '自分のスタイルで走ろう';

  @override
  String get onboardingBody4 => '数百のミッションに挑むもよし、果てしない景色の中をのんびり走るもよし。';

  @override
  String get menuPlay => 'プレイ';

  @override
  String get menuMissions => 'ミッション';

  @override
  String get menuFreeRide => 'フリーライド';

  @override
  String get menuEndless => 'エンドレス逃走';

  @override
  String get menuGarage => 'ガレージ';

  @override
  String get menuDaily => 'ログインボーナス';

  @override
  String get menuTasks => 'デイリータスク';

  @override
  String get menuAchievements => '実績';

  @override
  String get menuSettings => '設定';

  @override
  String get menuBack => '戻る';

  @override
  String get menuClose => '閉じる';

  @override
  String get menuConfirm => '決定';

  @override
  String get menuCancel => 'キャンセル';

  @override
  String get menuContinue => '続ける';

  @override
  String get currencyCoins => 'コイン';

  @override
  String get currencyGems => 'ジェム';

  @override
  String playerLevel(int level) {
    return 'レベル$level';
  }

  @override
  String xpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String bestDistance(String distance) {
    return 'ベスト：$distance';
  }

  @override
  String get rank1 => 'ルーキー';

  @override
  String get rank2 => 'ペダル見習い';

  @override
  String get rank3 => 'ストリートライダー';

  @override
  String get rank4 => 'トレイル開拓者';

  @override
  String get rank5 => 'スピード狂';

  @override
  String get rank6 => 'ストームチェイサー';

  @override
  String get rank7 => 'ロードキャプテン';

  @override
  String get rank8 => '山の王者';

  @override
  String get rank9 => 'レジェンド';

  @override
  String get rank10 => '不滅のペダル王';

  @override
  String get world1 => '陽だまりの草原';

  @override
  String get world2 => '紅葉の森';

  @override
  String get world3 => 'レッドキャニオン';

  @override
  String get world4 => '海岸ハイウェイ';

  @override
  String get world5 => 'ネオンシティ';

  @override
  String get world6 => '氷結の峰';

  @override
  String get world7 => 'エメラルドジャングル';

  @override
  String get world8 => '桜の谷';

  @override
  String get world9 => '錆びた埠頭';

  @override
  String get world10 => '失われた神殿';

  @override
  String get world11 => '火山峠';

  @override
  String get world12 => '星降るハイウェイ';

  @override
  String get levelSelectTitle => 'ミッション';

  @override
  String levelNumber(int number) {
    return 'ステージ$number';
  }

  @override
  String get levelLocked => 'ロック中';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと★$count個で解放',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => '先に前のステージをクリアしよう';

  @override
  String levelLength(String distance) {
    return '距離：$distance';
  }

  @override
  String get levelDifficulty => '難易度';

  @override
  String levelRecommendedPower(int power) {
    return '推奨パワー：$power';
  }

  @override
  String levelYourPower(int power) {
    return '現在の自転車：$power';
  }

  @override
  String get levelStart => 'スタート';

  @override
  String get levelObjectives => '目標';

  @override
  String get objectiveFinish => 'ゴールにたどり着く';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'コインを$count枚集める',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => '転倒せずにゴール';

  @override
  String objectiveTime(String time) {
    return '$time以内にゴール';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '★$count個',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return '$done / $total ステージ';
  }

  @override
  String get hudDistance => '距離';

  @override
  String hudToGo(String distance) {
    return '残り$distance';
  }

  @override
  String hudCombo(int multiplier) {
    return 'コンボ x$multiplier';
  }

  @override
  String get hudNearMiss => 'ニアミス！';

  @override
  String get hudPerfectJump => 'パーフェクトジャンプ！';

  @override
  String get hudStormClose => '嵐が迫っている！';

  @override
  String get hudGo => 'GO!';

  @override
  String get hudSpeed => 'km/h';

  @override
  String get tutorialSwipeSides => '左右にスワイプでレーン変更';

  @override
  String get tutorialSwipeUp => '上にスワイプでジャンプ';

  @override
  String get tutorialSwipeDown => '下にスワイプでしゃがむ';

  @override
  String get tutorialCollect => 'コインとパワーアップをゲット！';

  @override
  String get powerMagnet => 'マグネット';

  @override
  String get powerShield => 'シールド';

  @override
  String get powerTurbo => 'ターボ';

  @override
  String get powerDoubleCoins => 'コイン2倍';

  @override
  String get powerGhost => 'ゴースト';

  @override
  String get pauseTitle => 'ポーズ中';

  @override
  String get pauseResume => '再開';

  @override
  String get pauseRestart => 'リスタート';

  @override
  String get pauseQuit => 'メニューに戻る';

  @override
  String get crashTitle => '転倒！';

  @override
  String get crashCaught => '嵐に追いつかれた！';

  @override
  String get crashRevive => '復活';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ジェム$count個で復活',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'あきらめる';

  @override
  String crashProgress(int percent) {
    return 'ゴールまで$percent%到達';
  }

  @override
  String get crashSoClose => '惜しい！もう1回だけ？';

  @override
  String get resultLevelComplete => 'ステージクリア！';

  @override
  String get resultRunOver => 'ラン終了';

  @override
  String get resultNewRecord => '新記録！';

  @override
  String get resultDistance => '距離';

  @override
  String get resultCoins => 'コイン';

  @override
  String get resultTime => 'タイム';

  @override
  String get resultXp => 'XP';

  @override
  String get resultNearMisses => 'ニアミス';

  @override
  String get resultBestCombo => '最高コンボ';

  @override
  String get resultNextLevel => '次のステージ';

  @override
  String get resultRetry => 'リトライ';

  @override
  String get resultMenu => 'メニュー';

  @override
  String resultLevelUp(int level) {
    return 'レベルアップ！レベル$levelになった！';
  }

  @override
  String get resultBonusChest => 'ボーナス宝箱をゲット！';

  @override
  String get garageTitle => 'ガレージ';

  @override
  String get garageBikes => '自転車';

  @override
  String get garageUpgrades => '強化';

  @override
  String get garagePaint => 'カラー';

  @override
  String get garageBuy => '購入';

  @override
  String get garageSelect => 'これに乗る';

  @override
  String get garageSelected => '使用中';

  @override
  String get garageOwned => '所持済み';

  @override
  String garageRequiresLevel(int level) {
    return 'レベル$levelで解放';
  }

  @override
  String get garageNotEnough => 'コインが足りません';

  @override
  String get garageNotEnoughGems => 'ジェムが足りません';

  @override
  String garagePower(int power) {
    return 'パワー $power';
  }

  @override
  String get garageUpgrade => '強化';

  @override
  String get garageMaxed => 'MAX';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Lv $current/$max';
  }

  @override
  String get garagePurchased => '購入しました！';

  @override
  String get garageUpgraded => '強化完了！';

  @override
  String get garageBuyBikeFirst => '購入すると強化できます';

  @override
  String get statTopSpeed => '最高速度';

  @override
  String get statAcceleration => '加速';

  @override
  String get statHandling => 'ハンドリング';

  @override
  String get statJump => 'ジャンプ力';

  @override
  String get statDurability => '耐久力';

  @override
  String get statLuck => '運';

  @override
  String get bike1Name => 'シティクルーザー';

  @override
  String get bike1Desc => '乗り心地抜群のスチール製クラシック。遅いけど扱いやすい。';

  @override
  String get bike2Name => 'フィクシーフラッシュ';

  @override
  String get bike2Desc => '軽量シングルスピード。素早いレーン変更が得意。';

  @override
  String get bike3Name => 'BMXラスカル';

  @override
  String get bike3Desc => '小さなタイヤで大ジャンプ。トリックのために生まれた一台。';

  @override
  String get bike4Name => 'トレイルゴート';

  @override
  String get bike4Desc => '凸凹道もへっちゃらなタフなMTB。';

  @override
  String get bike5Name => 'グラベルノマド';

  @override
  String get bike5Desc => 'どんな道でもこなすバランス型オールラウンダー。';

  @override
  String get bike6Name => 'ファットイエティ';

  @override
  String get bike6Desc => '衝突も笑い飛ばすモンスタータイヤ。';

  @override
  String get bike7Name => 'ボルトEバイク';

  @override
  String get bike7Desc => '電動アシストで爆発的な加速。';

  @override
  String get bike8Name => 'カーボンアロー';

  @override
  String get bike8Desc => '最高速度に優れた超軽量ロードレーサー。';

  @override
  String get bike9Name => 'ダウンヒルビースト';

  @override
  String get bike9Desc => 'フルサスペンションと鋼の度胸。';

  @override
  String get bike10Name => 'トラックコメット';

  @override
  String get bike10Desc => 'バンクを駆けるロケット。まばたき厳禁！';

  @override
  String get bike11Name => 'シャドウステルス';

  @override
  String get bike11Desc => '幸運のコインを引き寄せるマットブラックのフレーム。';

  @override
  String get bike12Name => 'タイタンX';

  @override
  String get bike12Desc => '二輪に宿るチタンの鎧。';

  @override
  String get bike13Name => 'オーロラ試作機';

  @override
  String get bike13Desc => '光るホイールを備えた実験的テクノロジー。';

  @override
  String get bike14Name => 'フェニックスブレイズ';

  @override
  String get bike14Desc => '炎の軌跡を残す、ほぼ無敵の一台。';

  @override
  String get bike15Name => '天空のレジェンド';

  @override
  String get bike15Desc => '究極の自転車。真の伝説だけが乗りこなせる。';

  @override
  String get upgradeEngine => 'ギア比';

  @override
  String get upgradeEngineDesc => '最高速度がアップ。';

  @override
  String get upgradeChain => 'レーシングチェーン';

  @override
  String get upgradeChainDesc => '最高速度に早く到達。';

  @override
  String get upgradeSteering => 'ステアリング';

  @override
  String get upgradeSteeringDesc => 'レーン変更がすばやくなる。';

  @override
  String get upgradeSuspension => 'サスペンション';

  @override
  String get upgradeSuspensionDesc => '高く跳んで、やわらかく着地。';

  @override
  String get upgradeFrame => '強化フレーム';

  @override
  String get upgradeFrameDesc => '転倒するまでに耐えられる衝突が増える。';

  @override
  String get upgradeTires => 'グリップタイヤ';

  @override
  String get upgradeTiresDesc => 'つまずいた時の減速を軽減。';

  @override
  String get upgradeMagnet => 'マグネットコイル';

  @override
  String get upgradeMagnetDesc => 'マグネットの効果時間が延長。';

  @override
  String get upgradeShield => 'シールド発生装置';

  @override
  String get upgradeShieldDesc => 'シールドの効果時間が延長。';

  @override
  String get upgradeTurbo => 'ターボブースター';

  @override
  String get upgradeTurboDesc => 'ターボの効果時間が延長。';

  @override
  String get upgradeCoinBag => 'コインポーチ';

  @override
  String get upgradeCoinBagDesc => '拾うたびにもらえるコインが増える。';

  @override
  String get upgradeLuck => '幸運のお守り';

  @override
  String get upgradeLuckDesc => 'パワーアップとジェムの出現率アップ。';

  @override
  String get upgradeLights => 'ヘッドライト';

  @override
  String get upgradeLightsDesc => '夜でも遠くの障害物が見える。';

  @override
  String get paintName1 => 'ノーマル';

  @override
  String get paintName2 => 'クリムゾン';

  @override
  String get paintName3 => 'オーシャン';

  @override
  String get paintName4 => 'ライム';

  @override
  String get paintName5 => 'サンセット';

  @override
  String get paintName6 => 'ミッドナイト';

  @override
  String get paintName7 => 'ゴールド';

  @override
  String get paintName8 => 'キャンディ';

  @override
  String get dailyTitle => 'ログインボーナス';

  @override
  String dailyDay(int day) {
    return '$day日目';
  }

  @override
  String get dailyClaim => '受け取る';

  @override
  String get dailyClaimed => '受取済み';

  @override
  String get dailyComeBack => '明日はもっと豪華な報酬が待ってるよ！';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日連続',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => '報酬を受け取れます！';

  @override
  String dailyNextIn(String time) {
    return '次の報酬まで$time';
  }

  @override
  String get spinTitle => 'ラッキールーレット';

  @override
  String get spinButton => '回す！';

  @override
  String get spinFree => '無料で回せます';

  @override
  String spinUsed(String time) {
    return '次の無料まで$time';
  }

  @override
  String spinWon(String reward) {
    return '$rewardをゲット！';
  }

  @override
  String get chestTitle => 'ミステリー宝箱';

  @override
  String get chestOpen => 'タップで開ける';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '宝箱が$count個あります',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'デイリータスク';

  @override
  String tasksRefresh(String time) {
    return '新しいタスクまで$time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'コインを$count枚集める',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return '合計$distance走る';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '障害物を$count回飛び越える',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '障害物を$count回くぐる',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ニアミスを$count回決める',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'パワーアップを$count回使う',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ステージを$count個クリア',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'フリーライドで$distance走る';
  }

  @override
  String get taskClaim => '受け取る';

  @override
  String get taskDone => '達成';

  @override
  String get taskAllDone => '全タスク達成！ボーナス解放。';

  @override
  String get achievementsTitle => '実績';

  @override
  String get achDistance => 'ロングライダー';

  @override
  String achDistanceDesc(String distance) {
    return '累計$distance走る';
  }

  @override
  String get achCoins => 'トレジャーハンター';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'コインを累計$count枚集める',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'エアタイム';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回ジャンプする',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'ミッションマスター';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ステージを$count個クリア',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'スターコレクター';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '★を$count個獲得',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'コレクター';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '自転車を$count台所持',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'メカニック';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '強化を$count回購入',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => '命知らず';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ニアミスを$count回決める',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => '常連ライダー';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日連続でログイン',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => '逃走の達人';

  @override
  String achEndlessDesc(String distance) {
    return 'エンドレス1回で$distance到達';
  }

  @override
  String achTier(int tier) {
    return 'ランク$tier';
  }

  @override
  String get achReward => '報酬';

  @override
  String get achClaim => '受け取る';

  @override
  String get achCompleted => '達成済み';

  @override
  String get freeRideTitle => 'フリーライド';

  @override
  String get freeRideWorld => 'ワールド';

  @override
  String get freeRideTime => '時間帯';

  @override
  String get freeRideMorning => '朝';

  @override
  String get freeRideNoon => '昼';

  @override
  String get freeRideSunset => '夕暮れ';

  @override
  String get freeRideNight => '夜';

  @override
  String get freeRideCycle => '昼夜サイクル';

  @override
  String get freeRideWeather => '天気';

  @override
  String get weatherClear => '晴れ';

  @override
  String get weatherRain => '雨';

  @override
  String get weatherSnow => '雪';

  @override
  String get weatherFog => '霧';

  @override
  String get weatherLeaves => '落ち葉';

  @override
  String get freeRideTraffic => '交通量';

  @override
  String get freeRideTrafficNone => 'なし';

  @override
  String get freeRideTrafficLight => '少なめ';

  @override
  String get freeRideTrafficHeavy => '多め';

  @override
  String get freeRideStart => '走り出す';

  @override
  String get freeRideHint => '嵐もプレッシャーもなし。景色を楽しみながらコインを拾おう。';

  @override
  String get freeRideLocked => 'ミッションでこのワールドに到達すると解放';

  @override
  String get endlessTitle => 'エンドレス逃走';

  @override
  String get endlessHint => '嵐に捕まるまで、どこまで行ける？';

  @override
  String get endlessBest => '自己ベスト';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => '端末の言語';

  @override
  String get settingsSound => '効果音';

  @override
  String get settingsMusic => 'BGM';

  @override
  String get settingsVibration => 'バイブレーション';

  @override
  String get settingsGraphics => '画質';

  @override
  String get graphicsLow => '低';

  @override
  String get graphicsMedium => '中';

  @override
  String get graphicsHigh => '高';

  @override
  String get settingsSensitivity => 'スワイプ感度';

  @override
  String get settingsShowTutorial => 'チュートリアルを再表示';

  @override
  String get settingsReset => 'データをリセット';

  @override
  String get settingsResetConfirm => 'コイン、自転車、ステージの進行がすべて消去されます。よろしいですか？';

  @override
  String get settingsResetDone => 'リセットしました';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsOn => 'オン';

  @override
  String get settingsOff => 'オフ';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'コイン$count枚',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ジェム$count個',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'ミステリー宝箱';

  @override
  String get rewardCollect => '受け取る';

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
    return '$hours時間$minutes分';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'おかえり、ライダー！';

  @override
  String offlineEarnings(String count) {
    return '留守の間に仲間たちが$countコインを見つけてくれたよ';
  }

  @override
  String get newBikeAvailable => 'ガレージに新しい自転車が届いたよ！';

  @override
  String get almostThere => 'あと少し！';

  @override
  String get keepGoing => 'その調子！';

  @override
  String unlockedWorld(String world) {
    return '新ワールド解放：$world';
  }
}
