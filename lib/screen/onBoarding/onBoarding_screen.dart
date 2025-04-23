import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import '../auth/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  final VoidCallback onDone;
  const OnBoardingScreen({super.key, required this.onDone});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  bool showGetStartedButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page == 3.0) {
        setState(() => showGetStartedButton = true);
      } else {
        setState(() => showGetStartedButton = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light mode background
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              _buildOnboardingPage(
                'Welcome to Jocey Trading!',
                'assets/anim/trade-4.json',
                'We make trading simple and accessible for everyone.',
                isLocal: true,
              ),
              _buildOnboardingPage(
                'Simple Buying & Selling',
                'assets/anim/trade-3.json',
                'Trade effortlessly with just a few taps.',
                isLocal: true,
              ),
              _buildOnboardingPage(
                'Boost Your Earnings',
                'assets/anim/trade-1.json',
                'Trade effortlessly with just a few taps.',
                isLocal: true,
              ),
              _buildOnboardingPage(
                'Secure & Reliable Trading',
                'assets/anim/trade-5.json',
                'Your transactions are protected with top-notch security.',
                isLocal: true,
              ),
            ],
          ),
          if (showGetStartedButton)
            Align(
              alignment: const Alignment(0, 0.75),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.goNamed('login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.amber, // Golden button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          Container(
            alignment: const Alignment(0, 0.9),
            child: SmoothPageIndicator(
              controller: _controller,
              count: 4,
              effect: const WormEffect(
                activeDotColor: Colors.amber,
                dotColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(
      String title, String? imagePath, String description,
      {bool isLocal = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLocal
              ? Lottie.asset(imagePath!, height: 300, width: 300)
              : Lottie.network(imagePath!, height: 300, width: 300),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Black text for light mode
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87, // Slightly softer black
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
