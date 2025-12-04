import 'package:flutter/material.dart';
import 'package:levelup/widgets/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../pages/authScreens/login.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Find Your First Opportunity",
      description:
          "Kickstart your career journey with companies looking for fresh talent like you.",
      image: "assets/images/landingPageHero.png",
    ),
    OnboardingItem(
      title: "Level Up Your Future",
      description:
          "Connect with top employers, grow your skills, and take the next big step.",
      image: "assets/images/levelUp.jpg",
    ),
    OnboardingItem(
      title: "Make Your Career Shine",
      description:
          "Your future starts here — explore, apply, and succeed with us.",
      image: "assets/images/landingPageHero2.jpg",
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A), 
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A), // Dark gray container
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF333333), width: 1),
                  ),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Color(0xFF888888), 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(item: _onboardingItems[index]);
                },
              ),
            ),

            // Page Indicators
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ),

            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GradientButton(
                onPressed: () {
                  if (_currentPage == _onboardingItems.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                text: _currentPage == _onboardingItems.length - 1
                    ? "Get Started"
                    : "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _onboardingItems.length; i++) {
      indicators.add(
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: _currentPage == i ? 24.0 : 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            shape: _currentPage == i ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: _currentPage == i ? BorderRadius.circular(12) : null,
            color: _currentPage == i ? Color(0xFF6C63FF) : Color(0xFF333333),
          ),
        ),
      );
    }
    return indicators;
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingSlide({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration with modern container
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(item.image, fit: BoxFit.cover),
              ),
            ),
          ),

          SizedBox(height: 40),

          // Title
          Text(
            item.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white, // White text for dark background
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16),

          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFAAAAAA), 
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
