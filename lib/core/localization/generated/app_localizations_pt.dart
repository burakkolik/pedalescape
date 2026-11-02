// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Pedal Escape: Fuga de Bike';

  @override
  String get appShortName => 'Pedal Escape';

  @override
  String get appTagline => 'Fuja da tempestade. Pedale sem parar.';

  @override
  String get splashLoading => 'Enchendo os pneus...';

  @override
  String get splashTip1 => 'Deslize para cima para pular barreiras baixas.';

  @override
  String get splashTip2 => 'Deslize para baixo para se abaixar sob canos e galhos.';

  @override
  String get splashTip3 => 'Passar raspando enche o medidor de combo mais rápido.';

  @override
  String get splashTip4 => 'As melhorias ficam em cada bike para sempre.';

  @override
  String get splashTip5 => 'Volte todo dia — as recompensas da sequência aumentam.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingStart => 'Bora pedalar!';

  @override
  String get onboardingTitle1 => 'A tempestade está chegando';

  @override
  String get onboardingBody1 => 'Uma tempestade furiosa está te perseguindo por doze mundos. Pedale com tudo e não olhe para trás!';

  @override
  String get onboardingTitle2 => 'Deslize para sobreviver';

  @override
  String get onboardingBody2 => 'Deslize para a esquerda ou direita para trocar de pista, para cima para pular e para baixo para se abaixar.';

  @override
  String get onboardingTitle3 => 'Monte a bike dos sonhos';

  @override
  String get onboardingBody3 => 'Colete moedas, desbloqueie quinze bikes únicas e melhore cada peça delas.';

  @override
  String get onboardingTitle4 => 'Pedale do seu jeito';

  @override
  String get onboardingBody4 => 'Conclua centenas de missões ou passeie livremente por cenários sem fim.';

  @override
  String get menuPlay => 'Jogar';

  @override
  String get menuMissions => 'Missões';

  @override
  String get menuFreeRide => 'Passeio Livre';

  @override
  String get menuEndless => 'Fuga Infinita';

  @override
  String get menuGarage => 'Garagem';

  @override
  String get menuDaily => 'Prêmios Diários';

  @override
  String get menuTasks => 'Tarefas Diárias';

  @override
  String get menuAchievements => 'Conquistas';

  @override
  String get menuSettings => 'Configurações';

  @override
  String get menuBack => 'Voltar';

  @override
  String get menuClose => 'Fechar';

  @override
  String get menuConfirm => 'Confirmar';

  @override
  String get menuCancel => 'Cancelar';

  @override
  String get menuContinue => 'Continuar';

  @override
  String get currencyCoins => 'Moedas';

  @override
  String get currencyGems => 'Gemas';

  @override
  String playerLevel(int level) {
    return 'Nível $level';
  }

  @override
  String xpProgress(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String bestDistance(String distance) {
    return 'Recorde: $distance';
  }

  @override
  String get rank1 => 'Novato';

  @override
  String get rank2 => 'Pedalador';

  @override
  String get rank3 => 'Ciclista Urbano';

  @override
  String get rank4 => 'Desbravador';

  @override
  String get rank5 => 'Demônio Veloz';

  @override
  String get rank6 => 'Caça-Tempestades';

  @override
  String get rank7 => 'Capitão da Estrada';

  @override
  String get rank8 => 'Rei da Montanha';

  @override
  String get rank9 => 'Lenda';

  @override
  String get rank10 => 'Imortal do Pedal';

  @override
  String get world1 => 'Campos Ensolarados';

  @override
  String get world2 => 'Bosque de Outono';

  @override
  String get world3 => 'Cânion Vermelho';

  @override
  String get world4 => 'Rodovia Costeira';

  @override
  String get world5 => 'Cidade Neon';

  @override
  String get world6 => 'Picos Gelados';

  @override
  String get world7 => 'Selva Esmeralda';

  @override
  String get world8 => 'Vale das Cerejas';

  @override
  String get world9 => 'Docas Enferrujadas';

  @override
  String get world10 => 'Templo Perdido';

  @override
  String get world11 => 'Passo do Vulcão';

  @override
  String get world12 => 'Rodovia Estelar';

  @override
  String get levelSelectTitle => 'Missões';

  @override
  String levelNumber(int number) {
    return 'Nível $number';
  }

  @override
  String get levelLocked => 'Bloqueado';

  @override
  String levelStarsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Colete mais $count estrelas para desbloquear',
      one: 'Colete mais $count estrela para desbloquear',
    );
    return '$_temp0';
  }

  @override
  String get levelFinishPrevious => 'Conclua o nível anterior primeiro';

  @override
  String levelLength(String distance) {
    return 'Extensão: $distance';
  }

  @override
  String get levelDifficulty => 'Dificuldade';

  @override
  String levelRecommendedPower(int power) {
    return 'Poder recomendado: $power';
  }

  @override
  String levelYourPower(int power) {
    return 'Sua bike: $power';
  }

  @override
  String get levelStart => 'Começar';

  @override
  String get levelObjectives => 'Objetivos';

  @override
  String get objectiveFinish => 'Chegue à linha de chegada';

  @override
  String objectiveCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Colete $count moedas',
      one: 'Colete $count moeda',
    );
    return '$_temp0';
  }

  @override
  String get objectiveNoCrash => 'Termine sem cair';

  @override
  String objectiveTime(String time) {
    return 'Termine em até $time';
  }

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas',
      one: '$count estrela',
    );
    return '$_temp0';
  }

  @override
  String worldProgress(int done, int total) {
    return '$done / $total níveis';
  }

  @override
  String get hudDistance => 'Distância';

  @override
  String hudToGo(String distance) {
    return 'Faltam $distance';
  }

  @override
  String hudCombo(int multiplier) {
    return 'Combo x$multiplier';
  }

  @override
  String get hudNearMiss => 'Por um triz!';

  @override
  String get hudPerfectJump => 'Salto perfeito!';

  @override
  String get hudStormClose => 'A tempestade está perto!';

  @override
  String get hudGo => 'JÁ!';

  @override
  String get hudSpeed => 'km/h';

  @override
  String get tutorialSwipeSides => 'Deslize para os lados para trocar de pista';

  @override
  String get tutorialSwipeUp => 'Deslize para cima para pular';

  @override
  String get tutorialSwipeDown => 'Deslize para baixo para se abaixar';

  @override
  String get tutorialCollect => 'Pegue moedas e power-ups!';

  @override
  String get powerMagnet => 'Ímã';

  @override
  String get powerShield => 'Escudo';

  @override
  String get powerTurbo => 'Turbo';

  @override
  String get powerDoubleCoins => 'Moedas em Dobro';

  @override
  String get powerGhost => 'Modo Fantasma';

  @override
  String get pauseTitle => 'Pausado';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get pauseRestart => 'Reiniciar';

  @override
  String get pauseQuit => 'Sair para o Menu';

  @override
  String get crashTitle => 'Que tombo!';

  @override
  String get crashCaught => 'A tempestade te pegou!';

  @override
  String get crashRevive => 'Reviver';

  @override
  String crashReviveCost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reviver por $count gemas',
      one: 'Reviver por $count gema',
    );
    return '$_temp0';
  }

  @override
  String get crashGiveUp => 'Desistir';

  @override
  String crashProgress(int percent) {
    return 'Você completou $percent% do percurso';
  }

  @override
  String get crashSoClose => 'Foi por pouco! Só mais uma vez?';

  @override
  String get resultLevelComplete => 'Nível Concluído!';

  @override
  String get resultRunOver => 'Fim da Corrida';

  @override
  String get resultNewRecord => 'Novo recorde!';

  @override
  String get resultDistance => 'Distância';

  @override
  String get resultCoins => 'Moedas';

  @override
  String get resultTime => 'Tempo';

  @override
  String get resultXp => 'XP';

  @override
  String get resultNearMisses => 'Por um triz';

  @override
  String get resultBestCombo => 'Melhor combo';

  @override
  String get resultNextLevel => 'Próximo Nível';

  @override
  String get resultRetry => 'Tentar de novo';

  @override
  String get resultMenu => 'Menu';

  @override
  String resultLevelUp(int level) {
    return 'Subiu de nível! Agora você está no nível $level';
  }

  @override
  String get resultBonusChest => 'Baú bônus conquistado!';

  @override
  String get garageTitle => 'Garagem';

  @override
  String get garageBikes => 'Bikes';

  @override
  String get garageUpgrades => 'Melhorias';

  @override
  String get garagePaint => 'Pintura';

  @override
  String get garageBuy => 'Comprar';

  @override
  String get garageSelect => 'Usar esta';

  @override
  String get garageSelected => 'Em uso';

  @override
  String get garageOwned => 'Adquirida';

  @override
  String garageRequiresLevel(int level) {
    return 'Libera no nível $level';
  }

  @override
  String get garageNotEnough => 'Moedas insuficientes';

  @override
  String get garageNotEnoughGems => 'Gemas insuficientes';

  @override
  String garagePower(int power) {
    return 'Poder $power';
  }

  @override
  String get garageUpgrade => 'Melhorar';

  @override
  String get garageMaxed => 'No máximo';

  @override
  String garageUpgradeLevel(int current, int max) {
    return 'Nv $current/$max';
  }

  @override
  String get garagePurchased => 'Comprada!';

  @override
  String get garageUpgraded => 'Melhorada!';

  @override
  String get garageBuyBikeFirst => 'Compre esta bike para melhorá-la';

  @override
  String get statTopSpeed => 'Velocidade máx.';

  @override
  String get statAcceleration => 'Aceleração';

  @override
  String get statHandling => 'Controle';

  @override
  String get statJump => 'Salto';

  @override
  String get statDurability => 'Resistência';

  @override
  String get statLuck => 'Sorte';

  @override
  String get bike1Name => 'Urbana Clássica';

  @override
  String get bike1Desc => 'Um clássico de aço confortável. Lenta, mas tolerante.';

  @override
  String get bike2Name => 'Fixa Relâmpago';

  @override
  String get bike2Desc => 'Leve e de marcha única, feita para trocar de pista rápido.';

  @override
  String get bike3Name => 'BMX Arteira';

  @override
  String get bike3Desc => 'Rodas pequenas, saltos enormes. Nasceu para manobras.';

  @override
  String get bike4Name => 'Cabra da Trilha';

  @override
  String get bike4Desc => 'Uma mountain bike durona que nem sente os buracos.';

  @override
  String get bike5Name => 'Nômade Gravel';

  @override
  String get bike5Desc => 'Equilibrada e versátil para qualquer tipo de estrada.';

  @override
  String get bike6Name => 'Yeti Fat';

  @override
  String get bike6Desc => 'Pneus monstruosos que riem das quedas.';

  @override
  String get bike7Name => 'E-Bike Volt';

  @override
  String get bike7Desc => 'Assistência elétrica para uma aceleração alucinante.';

  @override
  String get bike8Name => 'Flecha de Carbono';

  @override
  String get bike8Desc => 'Speed ultraleve com velocidade máxima de respeito.';

  @override
  String get bike9Name => 'Fera do Downhill';

  @override
  String get bike9Desc => 'Suspensão total e nervos de aço.';

  @override
  String get bike10Name => 'Cometa da Pista';

  @override
  String get bike10Desc => 'Um foguete de velódromo. Piscou, perdeu.';

  @override
  String get bike11Name => 'Sombra Furtiva';

  @override
  String get bike11Desc => 'Quadro preto fosco que atrai moedas da sorte.';

  @override
  String get bike12Name => 'Titã X';

  @override
  String get bike12Desc => 'Armadura de titânio sobre duas rodas.';

  @override
  String get bike13Name => 'Protótipo Aurora';

  @override
  String get bike13Desc => 'Tecnologia experimental com rodas brilhantes.';

  @override
  String get bike14Name => 'Fênix Flamejante';

  @override
  String get bike14Desc => 'Deixa um rastro de fogo. Quase imparável.';

  @override
  String get bike15Name => 'Lenda Celestial';

  @override
  String get bike15Desc => 'A bike definitiva. Só verdadeiras lendas a pilotam.';

  @override
  String get upgradeEngine => 'Transmissão';

  @override
  String get upgradeEngineDesc => 'Aumenta sua velocidade máxima.';

  @override
  String get upgradeChain => 'Corrente Pro';

  @override
  String get upgradeChainDesc => 'Alcance a velocidade máxima mais rápido.';

  @override
  String get upgradeSteering => 'Direção';

  @override
  String get upgradeSteeringDesc => 'Troque de pista mais rápido.';

  @override
  String get upgradeSuspension => 'Suspensão';

  @override
  String get upgradeSuspensionDesc => 'Pule mais alto e aterrisse mais suave.';

  @override
  String get upgradeFrame => 'Quadro Reforçado';

  @override
  String get upgradeFrameDesc => 'Aguente mais batidas antes de cair.';

  @override
  String get upgradeTires => 'Pneus Aderentes';

  @override
  String get upgradeTiresDesc => 'Perde menos velocidade ao tropeçar.';

  @override
  String get upgradeMagnet => 'Bobina Magnética';

  @override
  String get upgradeMagnetDesc => 'O power-up Ímã dura mais.';

  @override
  String get upgradeShield => 'Gerador de Escudo';

  @override
  String get upgradeShieldDesc => 'O power-up Escudo dura mais.';

  @override
  String get upgradeTurbo => 'Propulsor Turbo';

  @override
  String get upgradeTurboDesc => 'O power-up Turbo dura mais.';

  @override
  String get upgradeCoinBag => 'Bolsa de Moedas';

  @override
  String get upgradeCoinBagDesc => 'Ganhe mais moedas a cada coleta.';

  @override
  String get upgradeLuck => 'Amuleto da Sorte';

  @override
  String get upgradeLuckDesc => 'Power-ups e gemas aparecem com mais frequência.';

  @override
  String get upgradeLights => 'Farol';

  @override
  String get upgradeLightsDesc => 'Veja obstáculos de mais longe à noite.';

  @override
  String get paintName1 => 'Original';

  @override
  String get paintName2 => 'Carmesim';

  @override
  String get paintName3 => 'Oceano';

  @override
  String get paintName4 => 'Lima';

  @override
  String get paintName5 => 'Pôr do Sol';

  @override
  String get paintName6 => 'Meia-noite';

  @override
  String get paintName7 => 'Ouro';

  @override
  String get paintName8 => 'Doce';

  @override
  String get dailyTitle => 'Prêmios Diários';

  @override
  String dailyDay(int day) {
    return 'Dia $day';
  }

  @override
  String get dailyClaim => 'Resgatar';

  @override
  String get dailyClaimed => 'Resgatado';

  @override
  String get dailyComeBack => 'Volte amanhã para um prêmio maior!';

  @override
  String dailyStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de $count dia',
    );
    return '$_temp0';
  }

  @override
  String get dailyAvailable => 'Prêmio disponível!';

  @override
  String dailyNextIn(String time) {
    return 'Próximo prêmio em $time';
  }

  @override
  String get spinTitle => 'Roleta da Sorte';

  @override
  String get spinButton => 'Girar!';

  @override
  String get spinFree => 'Giro grátis disponível';

  @override
  String spinUsed(String time) {
    return 'Próximo giro grátis em $time';
  }

  @override
  String spinWon(String reward) {
    return 'Você ganhou $reward!';
  }

  @override
  String get chestTitle => 'Baú Misterioso';

  @override
  String get chestOpen => 'Toque para abrir';

  @override
  String chestCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baús esperando',
      one: '$count baú esperando',
    );
    return '$_temp0';
  }

  @override
  String get tasksTitle => 'Tarefas Diárias';

  @override
  String tasksRefresh(String time) {
    return 'Novas tarefas em $time';
  }

  @override
  String taskCollectCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Colete $count moedas',
      one: 'Colete $count moeda',
    );
    return '$_temp0';
  }

  @override
  String taskRideDistance(String distance) {
    return 'Pedale $distance no total';
  }

  @override
  String taskJump(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pule $count obstáculos',
      one: 'Pule $count obstáculo',
    );
    return '$_temp0';
  }

  @override
  String taskDuck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Abaixe-se sob $count obstáculos',
      one: 'Abaixe-se sob $count obstáculo',
    );
    return '$_temp0';
  }

  @override
  String taskNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Passe raspando $count vezes',
      one: 'Passe raspando $count vez',
    );
    return '$_temp0';
  }

  @override
  String taskPowerUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Use $count power-ups',
      one: 'Use $count power-up',
    );
    return '$_temp0';
  }

  @override
  String taskLevels(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conclua $count níveis',
      one: 'Conclua $count nível',
    );
    return '$_temp0';
  }

  @override
  String taskFreeRide(String distance) {
    return 'Pedale $distance no Passeio Livre';
  }

  @override
  String get taskClaim => 'Resgatar';

  @override
  String get taskDone => 'Feito';

  @override
  String get taskAllDone => 'Todas as tarefas concluídas! Bônus liberado.';

  @override
  String get achievementsTitle => 'Conquistas';

  @override
  String get achDistance => 'Longa Jornada';

  @override
  String achDistanceDesc(String distance) {
    return 'Pedale $distance no total';
  }

  @override
  String get achCoins => 'Caça-Tesouros';

  @override
  String achCoinsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Colete $count moedas no total',
      one: 'Colete $count moeda no total',
    );
    return '$_temp0';
  }

  @override
  String get achJumps => 'Nas Alturas';

  @override
  String achJumpsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pule $count vezes',
      one: 'Pule $count vez',
    );
    return '$_temp0';
  }

  @override
  String get achLevels => 'Mestre das Missões';

  @override
  String achLevelsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Conclua $count níveis',
      one: 'Conclua $count nível',
    );
    return '$_temp0';
  }

  @override
  String get achStars => 'Caça-Estrelas';

  @override
  String achStarsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ganhe $count estrelas',
      one: 'Ganhe $count estrela',
    );
    return '$_temp0';
  }

  @override
  String get achBikes => 'Colecionador';

  @override
  String achBikesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tenha $count bikes',
      one: 'Tenha $count bike',
    );
    return '$_temp0';
  }

  @override
  String get achUpgrades => 'Mecânico';

  @override
  String achUpgradesDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compre $count melhorias',
      one: 'Compre $count melhoria',
    );
    return '$_temp0';
  }

  @override
  String get achNearMiss => 'Destemido';

  @override
  String achNearMissDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Passe raspando $count vezes',
      one: 'Passe raspando $count vez',
    );
    return '$_temp0';
  }

  @override
  String get achStreak => 'Ciclista Fiel';

  @override
  String achStreakDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entre $count dias seguidos',
      one: 'Entre $count dia seguido',
    );
    return '$_temp0';
  }

  @override
  String get achEndless => 'Mestre da Fuga';

  @override
  String achEndlessDesc(String distance) {
    return 'Alcance $distance em uma única Fuga Infinita';
  }

  @override
  String achTier(int tier) {
    return 'Nível $tier';
  }

  @override
  String get achReward => 'Recompensa';

  @override
  String get achClaim => 'Resgatar';

  @override
  String get achCompleted => 'Concluída';

  @override
  String get freeRideTitle => 'Passeio Livre';

  @override
  String get freeRideWorld => 'Mundo';

  @override
  String get freeRideTime => 'Hora do dia';

  @override
  String get freeRideMorning => 'Manhã';

  @override
  String get freeRideNoon => 'Meio-dia';

  @override
  String get freeRideSunset => 'Pôr do sol';

  @override
  String get freeRideNight => 'Noite';

  @override
  String get freeRideCycle => 'Ciclo dia e noite';

  @override
  String get freeRideWeather => 'Clima';

  @override
  String get weatherClear => 'Limpo';

  @override
  String get weatherRain => 'Chuva';

  @override
  String get weatherSnow => 'Neve';

  @override
  String get weatherFog => 'Neblina';

  @override
  String get weatherLeaves => 'Folhas caindo';

  @override
  String get freeRideTraffic => 'Trânsito';

  @override
  String get freeRideTrafficNone => 'Nenhum';

  @override
  String get freeRideTrafficLight => 'Leve';

  @override
  String get freeRideTrafficHeavy => 'Intenso';

  @override
  String get freeRideStart => 'Começar passeio';

  @override
  String get freeRideHint => 'Sem tempestade, sem pressão. Curta o passeio e pegue moedas pelo caminho.';

  @override
  String get freeRideLocked => 'Alcance este mundo nas Missões para desbloqueá-lo';

  @override
  String get endlessTitle => 'Fuga Infinita';

  @override
  String get endlessHint => 'Até onde você consegue ir antes que a tempestade te alcance?';

  @override
  String get endlessBest => 'Recorde pessoal';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma do celular';

  @override
  String get settingsSound => 'Efeitos sonoros';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsVibration => 'Vibração';

  @override
  String get settingsGraphics => 'Qualidade gráfica';

  @override
  String get graphicsLow => 'Baixa';

  @override
  String get graphicsMedium => 'Média';

  @override
  String get graphicsHigh => 'Alta';

  @override
  String get settingsSensitivity => 'Sensibilidade do toque';

  @override
  String get settingsShowTutorial => 'Ver tutorial de novo';

  @override
  String get settingsReset => 'Redefinir progresso';

  @override
  String get settingsResetConfirm => 'Isso apaga todas as moedas, bikes e níveis. Tem certeza?';

  @override
  String get settingsResetDone => 'Progresso redefinido';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsOn => 'Ligado';

  @override
  String get settingsOff => 'Desligado';

  @override
  String rewardCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moedas',
      one: '$count moeda',
    );
    return '$_temp0';
  }

  @override
  String rewardGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemas',
      one: '$count gema',
    );
    return '$_temp0';
  }

  @override
  String get rewardChest => 'Baú misterioso';

  @override
  String get rewardCollect => 'Coletar';

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
    return '${hours}h ${minutes}min';
  }

  @override
  String timeMinutesSeconds(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get welcomeBack => 'Bem-vindo de volta, ciclista!';

  @override
  String offlineEarnings(String count) {
    return 'Sua equipe encontrou $count moedas enquanto você estava fora';
  }

  @override
  String get newBikeAvailable => 'Uma bike nova está esperando na garagem!';

  @override
  String get almostThere => 'Quase lá!';

  @override
  String get keepGoing => 'Continue assim!';

  @override
  String unlockedWorld(String world) {
    return 'Novo mundo desbloqueado: $world';
  }
}
