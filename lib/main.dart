import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'game/game_controller.dart';
import 'screens/main_menu_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_board_screen.dart';
import 'screens/research_shop_screen.dart';
import 'screens/market_screen.dart';
import 'screens/galaxies_map_screen.dart';
import 'screens/galaxy_board_screen.dart';
import 'screens/command_bridge_screen.dart';
import 'theme/style_guide.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait for mobile phone gameplay
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Hide system overlays for full screen vibe
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Destroyer',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: StyleGuide.neutralBg,
        colorScheme: const ColorScheme.dark(
          primary: StyleGuide.primary,
          secondary: StyleGuide.tertiary,
          surface: StyleGuide.neutralCard,
        ),
        useMaterial3: true,
      ),
      home: const GameRouter(),
    );
  }
}

class GameRouter extends StatefulWidget {
  const GameRouter({super.key});

  @override
  State<GameRouter> createState() => _GameRouterState();
}

class _GameRouterState extends State<GameRouter> {
  // Screens: 'menu', 'bridge', 'select', 'game', 'shop', 'market', 'galaxies', 'galaxy_board'
  String _currentScreen = 'menu';
  final List<String> _screenHistory = ['menu'];
  String _selectedGalaxyId = '';
  final GameController _controller = GameController();

  void _navigateTo(String screen) {
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (_) {
      // Safe fallback if called during build
    }
    setState(() {
      if (screen == 'menu') {
        _screenHistory.clear();
        _screenHistory.add('menu');
      } else {
        if (_screenHistory.isEmpty || _screenHistory.last != screen) {
          _screenHistory.add(screen);
        }
      }
      _currentScreen = screen;
    });
  }

  void _goBack() {
    setState(() {
      if (_screenHistory.length > 1) {
        _screenHistory.removeLast();
        _currentScreen = _screenHistory.last;
      } else {
        _currentScreen = 'bridge';
        _screenHistory.clear();
        _screenHistory.add('bridge');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 'menu':
        return MainMenuScreen(
          onEnterBridge: () => _navigateTo('bridge'),
        );
      case 'bridge':
        return CommandBridgeScreen(
          controller: _controller,
          onStartCampaign: () => _navigateTo('galaxies'),
          onStartGame: () => _navigateTo('select'),
          onOpenShop: () => _navigateTo('shop'),
          onOpenMarket: () => _navigateTo('market'),
          onBackToMenu: () => _navigateTo('menu'),
        );
      case 'select':
        return LevelSelectScreen(
          controller: _controller,
          onLevelSelected: (levelId) {
            _controller.loadLevel(levelId);
            _navigateTo('game');
          },
          onBackToMenu: () => _navigateTo('bridge'),
        );
      case 'game':
        return GameBoardScreen(
          controller: _controller,
          onBackToMenu: () => _navigateTo(_controller.activeQuest != null ? 'galaxy_board' : 'select'),
          onGoToShop: () => _navigateTo('market'),
          onGoToResearch: () => _navigateTo('shop'),
        );
      case 'shop':
        return ResearchShopScreen(
          controller: _controller,
          onBackToGame: () => _goBack(),
          onGoToShop: () => _navigateTo('market'),
        );
      case 'market':
        return MarketScreen(
          controller: _controller,
          onBackToMenu: () => _goBack(),
          onGoToResearch: () => _navigateTo('shop'),
        );
      case 'galaxies':
        return GalaxiesMapScreen(
          controller: _controller,
          onGalaxySelected: (galaxyId) {
            setState(() {
              _selectedGalaxyId = galaxyId;
            });
            _navigateTo('galaxy_board');
          },
          onBackToMenu: () => _navigateTo('bridge'),
          onGoToShop: () => _navigateTo('market'),
          onGoToResearch: () => _navigateTo('shop'),
        );
      case 'galaxy_board':
        return GalaxyBoardScreen(
          controller: _controller,
          galaxyId: _selectedGalaxyId,
          onQuestSelected: (quest) {
            _controller.loadQuest(quest);
            _navigateTo('game');
          },
          onBackToMap: () => _navigateTo('galaxies'),
          onGoToShop: () => _navigateTo('market'),
          onGoToResearch: () => _navigateTo('shop'),
        );
      default:
        return MainMenuScreen(
          onEnterBridge: () => _navigateTo('bridge'),
        );
    }
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
