import 'package:circle_bottom_navigation/widgets/tab_data.dart';
import 'package:flutter/material.dart';
import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../service/auth_service.dart';
import '../main/home_screen.dart';
import '../main/market_screen.dart';
import '../main/profile_screen.dart';
import '../main/trading_screen.dart';
import '../main/wallet_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPage = 0;
  bool isAuthenticating = true; // To handle biometric authentication state
  final AuthFingerprintService _authService = AuthFingerprintService(); // Biometric Auth Service

  final List<Widget> screens = [
    HomeScreen(),
    MarketScreen(),
    TradingScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _authenticateUser(); // Call biometric authentication before showing the screen
  }

  /// *Authenticate user before showing the screen*
  Future<void> _authenticateUser() async {
    bool isAuthenticated = await _authService.authenticate();

    if (!isAuthenticated) {
      // If authentication fails, navigate back to login
      Navigator.pop(context);
      return;
    }

    // If authentication is successful, proceed to initialize the app
    setState(() {
      isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // *Show authentication screen before loading app content*
    if (isAuthenticating) {
      return _buildAuthLoadingScreen();
    }

    return Scaffold(
      body: screens[currentPage], // Show the screen based on selected tab
      bottomNavigationBar: CircleBottomNavigation(
        initialSelection: currentPage,
        tabs: [
          TabData(
            icon: Icons.home,
            title: 'Home',
          ),
          TabData(
            icon: FontAwesomeIcons.chartLine, // Icon for Market
            title: 'Market',
          ),
          TabData(
            icon: FontAwesomeIcons.horseHead, // Horse icon
            title: 'Trade',
          ),
          TabData(
            icon: FontAwesomeIcons.wallet,
            title: 'Wallet',
          ),
          TabData(
            icon: Icons.person,
            title: 'Profile',
          ),
        ],
        onTabChangedListener: (index) => setState(() {
          currentPage = index;
        }),
        circleColor: Colors.amber, // Circle color
        activeIconColor: Colors.black, // Active icon color
        inactiveIconColor: Colors.grey, // Inactive icon color
        textColor: Colors.black, // Text color for the title
        barBackgroundColor: Colors.white, // Background color of the bottom bar
        circleSize: 60.0, // Size of the inner circle
        barHeight: 60.0, // Height of the bottom bar
        arcHeight: 70.0, // External circle arc height
        arcWidth: 90.0, // External circle arc width
        circleOutline: 10.0, // Outline of the circle
        shadowAllowance: 20.0, // Size of icon shadow
        hasElevationShadows: true, // Elevation shadows
        blurShadowRadius: 8.0, // Size of bar shadow if hasElevationShadows is true
      ),

    );
  }

  /// *Authentication Loading Screen*
  Widget _buildAuthLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
      
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: 100, color: Color(0xFF0A0E21)),
              SizedBox(height: 10),
              Text("Authenticating...", style: TextStyle(fontSize: 18, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}