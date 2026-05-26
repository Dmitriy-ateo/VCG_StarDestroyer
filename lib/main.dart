import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/game_controller.dart';
import 'screens/main_menu_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/game_board_screen.dart';
import 'screens/research_shop_screen.dart';
import 'screens/market_screen.dart';

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
      title: 'Star Destroyer: Single Shot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00ADB5),
          secondary: Color(0xFF00FFF5),
          surface: Color(0xFF161B22),
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
  // Screens: 'menu', 'select', 'game', 'shop', 'market'
  String _currentScreen = 'menu';
  String _previousScreen = 'menu';
  final GameController _controller = GameController();

  void _navigateTo(String screen) {
    setState(() {
      _previousScreen = _currentScreen;
      _currentScreen = screen;
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
          onStartGame: () => _navigateTo('select'),
          onOpenShop: () => _navigateTo('shop'),
          onOpenMarket: () => _navigateTo('market'),
        );
      case 'select':
        return LevelSelectScreen(
          controller: _controller,
          onLevelSelected: (levelId) {
            _controller.loadLevel(levelId);
            _navigateTo('game');
          },
          onBackToMenu: () => _navigateTo('menu'),
        );
      case 'game':
        return GameBoardScreen(
          controller: _controller,
          onBackToMenu: () => _navigateTo('select'),
          onGoToShop: () => _navigateTo('shop'),
        );
      case 'shop':
        return ResearchShopScreen(
          controller: _controller,
          onBackToGame: () {
            // Exiting shop returns to game board if entered from game, else returns to menu.
            _navigateTo(_previousScreen == 'game' ? 'game' : 'menu');
          },
        );
      case 'market':
        return MarketScreen(
          controller: _controller,
          onBackToMenu: () {
            // Exiting market returns to game board if entered from game, else returns to menu.
            _navigateTo(_previousScreen == 'game' ? 'game' : 'menu');
          },
        );
      default:
        return MainMenuScreen(
          onStartGame: () => _navigateTo('select'),
          onOpenShop: () => _navigateTo('shop'),
          onOpenMarket: () => _navigateTo('market'),
        );
    }
  }
}
