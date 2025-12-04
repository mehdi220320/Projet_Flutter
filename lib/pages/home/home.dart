import 'package:flutter/material.dart';
import 'package:levelup/pages/authScreens/login.dart';
import 'package:levelup/pages/home/intershipPage.dart';
import 'package:levelup/pages/home/swipe_page.dart';
import 'package:levelup/pages/home/favorites_page.dart';
import 'package:levelup/pages/home/ApplicationHistory_page.dart';
import 'package:levelup/pages/screens/helpANDsupportScreen.dart';
import 'package:levelup/pages/screens/profile_page.dart';
import 'package:levelup/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levelup/models/Offer.dart';
import 'dart:convert';
import 'package:levelup/providers/offer_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentBottomNavIndex = 0;
  List<Offer> _favoriteOffers = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      offerProvider.fetchRecommendedOffers();
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorite_offers') ?? [];

    setState(() {
      _favoriteOffers = favoritesJson.map((jsonString) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return Offer.fromJson(jsonMap);
      }).toList();
    });
  }

  Future<void> _updateFavorites(List<Offer> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = favorites
        .map((offer) => json.encode(offer.toJson()))
        .toList();
    await prefs.setStringList('favorite_offers', favoritesJson);

    setState(() {
      _favoriteOffers = favorites;
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuOption(Icons.person, "Profile"),
            _buildMenuOption(Icons.settings, "Settings"),
            _buildMenuOption(Icons.help, "Help & Support"),
            _buildMenuOption(Icons.logout, "Logout"),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () async {
        if (text == "Logout") {
          await Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        } else if (text == "Profile") {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (text == "Help & Support") {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpSupportPage()),
          );
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentBottomNavIndex) {
      case 0:
        return "JobSwipe";
      case 1:
        return "Favorites (${_favoriteOffers.length})";
      case 2:
        return "History";
      case 3:
        return "Internship Request";
      default:
        return "JobSwipe";
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentBottomNavIndex) {
      case 0:
        return SwipePage(
          favoriteOffers: _favoriteOffers,
          onFavoritesUpdated: _updateFavorites,
        );
      case 1:
        return FavoritesPage(
          favoriteOffers: _favoriteOffers,
          onFavoritesUpdated: _updateFavorites,
          onRefreshFavorites: _loadFavorites,
        );
      case 2:
        return const ApplicationHistoryPage();
      case 3:
        return const InternshipDemandsPage();

      default:
        return const SizedBox();
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentBottomNavIndex,
      onTap: (index) => setState(() => _currentBottomNavIndex = index),
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.swipe),
          label: 'Swipe Jobs',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.favorite),
              if (_favoriteOffers.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      _favoriteOffers.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Favorites',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.school_sharp),
          label: 'Internship Request',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _showMenu,
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
