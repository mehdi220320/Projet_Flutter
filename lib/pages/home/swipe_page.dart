import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:levelup/models/Offer.dart';
import 'package:provider/provider.dart';
import 'package:levelup/providers/offer_provider.dart';

class SwipePage extends StatefulWidget {
  final List<Offer> favoriteOffers;
  final Function(List<Offer>) onFavoritesUpdated;

  const SwipePage({
    super.key,
    required this.favoriteOffers,
    required this.onFavoritesUpdated,
  });

  @override
  SwipePageState createState() => SwipePageState();
}

class SwipePageState extends State<SwipePage> with TickerProviderStateMixin {
  bool _showLike = false;
  bool _showNope = false;
  int _currentCardIndex = 0;

  late AnimationController _likeController;
  late AnimationController _nopeController;
  late AnimationController _infoController;
  late Animation<double> _likeScaleAnimation;
  late Animation<double> _nopeScaleAnimation;
  late Animation<double> _likeOpacityAnimation;
  late Animation<double> _nopeOpacityAnimation;
  late Animation<double> _infoScaleAnimation;
  late Animation<double> _infoOpacityAnimation;

  final CardSwiperController _swiperController = CardSwiperController();

  // Add this list to track canceled offers
  final List<Offer> _canceledOffers = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _nopeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _infoController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _likeScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );

    _likeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _nopeScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _nopeController, curve: Curves.elasticOut),
    );

    _nopeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _nopeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _infoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _infoController, curve: Curves.easeOutBack),
    );

    _infoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _infoController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _nopeController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  // Add this method to filter offers
  List<Offer> _getFilteredOffers(List<Offer> allOffers) {
    return allOffers.where((offer) {
      // Remove offers that are in favorites
      final isInFavorites = widget.favoriteOffers.any(
        (fav) => fav.id == offer.id,
      );
      // Remove offers that are canceled
      final isCanceled = _canceledOffers.any(
        (canceled) => canceled.id == offer.id,
      );
      // Remove offers that are closed
      final isClosed = offer.isClosed;

      return !isInFavorites && !isCanceled && !isClosed;
    }).toList();
  }

  void _showSwipeFeedback(bool isLike) {
    setState(() {
      _showLike = isLike;
      _showNope = !isLike;
    });

    final controller = isLike ? _likeController : _nopeController;
    controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        controller.reset();
        setState(() {
          _showLike = false;
          _showNope = false;
        });
      });
    });
  }

  void _handleButtonTap(bool isLike) {
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    final allOffers = offerProvider.recommendedOffers;
    final filteredOffers = _getFilteredOffers(allOffers);

    if (filteredOffers.isEmpty) return;

    _showSwipeFeedback(isLike);

    // Get the current offer from filtered list
    final currentOffer = filteredOffers[_currentCardIndex];

    if (isLike) {
      // Add to favorites when liking
      List<Offer> updatedFavorites = List.from(widget.favoriteOffers);
      if (!updatedFavorites.any((fav) => fav.id == currentOffer.id)) {
        updatedFavorites.add(currentOffer);
        widget.onFavoritesUpdated(updatedFavorites);
      }
    } else {
      // Add to canceled offers when disliking
      if (!_canceledOffers.any((canceled) => canceled.id == currentOffer.id)) {
        setState(() {
          _canceledOffers.add(currentOffer);
        });
      }
    }

    // Swipe the card
    if (isLike) {
      _swiperController.swipe(CardSwiperDirection.right);
    } else {
      _swiperController.swipe(CardSwiperDirection.left);
    }
  }

  void _showInfoPopup() {
    _infoController.forward();
    Future.delayed(const Duration(seconds: 3), () {
      _infoController.reverse();
    });
  }

  void _showExtendedInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 24),
                    SizedBox(width: 10),
                    Text(
                      "How to Use JobSwipe",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInstructionItem(
                  Icons.thumb_up_alt,
                  "Swipe Right / Heart Button",
                  "Adds job to your favorites and shows you more like this",
                  Colors.green,
                ),
                const SizedBox(height: 15),
                _buildInstructionItem(
                  Icons.close,
                  "Swipe Left / X Button",
                  "Removes job from your list and skips to next opportunity",
                  Colors.red,
                ),
                const SizedBox(height: 15),
                _buildInstructionItem(
                  Icons.favorite,
                  "Favorites Tab",
                  "View all your saved jobs in one place for easy access",
                  Colors.pink,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Got it!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            "Loading job offers...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          SizedBox(height: 20),
          Text(
            "Error loading offers",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final offerProvider = Provider.of<OfferProvider>(
                context,
                listen: false,
              );
              offerProvider.fetchRecommendedOffers();
            },
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: Colors.white.withOpacity(0.5),
            size: 60,
          ),
          SizedBox(height: 20),
          Text(
            "No more job offers available",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You've seen all available opportunities\nCheck back later for new jobs",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Reset canceled offers to see all offers again
              setState(() {
                _canceledOffers.clear();
              });
            },
            child: Text("Reset and Show All Offers"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, offerProvider, child) {
        if (offerProvider.loading) {
          return _buildLoadingState();
        }

        if (offerProvider.error != null) {
          return _buildErrorState(offerProvider.error!);
        }

        final filteredOffers = _getFilteredOffers(
          offerProvider.recommendedOffers,
        );

        if (filteredOffers.isEmpty) {
          return _buildEmptyState();
        }

        return Stack(
          children: [
            _buildSwiper(filteredOffers),

            // Info Popup
            AnimatedBuilder(
              animation: _infoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _infoOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _infoScaleAnimation.value,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 100),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up_alt,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Like = Save to Favorites",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.close, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Dislike = Skip",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSwiper(List<Offer> filteredOffers) {
    return Stack(
      children: [
        CardSwiper(
          controller: _swiperController,
          cardsCount: filteredOffers.length,
          onSwipe: (prev, current, direction) {
            if (current != null) {
              setState(() {
                _currentCardIndex = current;
              });
            }

            final currentOffer = filteredOffers[_currentCardIndex];

            if (direction == CardSwiperDirection.right) {
              // Add to favorites
              List<Offer> updatedFavorites = List.from(widget.favoriteOffers);
              if (!updatedFavorites.any((fav) => fav.id == currentOffer.id)) {
                updatedFavorites.add(currentOffer);
                widget.onFavoritesUpdated(updatedFavorites);
              }
              _showSwipeFeedback(true);
            } else if (direction == CardSwiperDirection.left) {
              // Add to canceled offers
              if (!_canceledOffers.any(
                (canceled) => canceled.id == currentOffer.id,
              )) {
                setState(() {
                  _canceledOffers.add(currentOffer);
                });
              }
              _showSwipeFeedback(false);
            }
            return true;
          },
          cardBuilder: (context, index, percentX, percentY) {
            final offer = filteredOffers[index];
            return _buildOfferCard(offer);
          },
          numberOfCardsDisplayed: 1,
          isLoop: true,
          padding: EdgeInsets.zero,
        ),

        // Swipe Feedback Animations
        if (_showLike)
          AnimatedBuilder(
            animation: _likeController,
            builder: (context, child) {
              return Opacity(
                opacity: _likeOpacityAnimation.value,
                child: Container(
                  color: Colors.green.withOpacity(
                    0.3 * _likeOpacityAnimation.value,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _likeScaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.thumb_up_alt,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        if (_showNope)
          AnimatedBuilder(
            animation: _nopeController,
            builder: (context, child) {
              return Opacity(
                opacity: _nopeOpacityAnimation.value,
                child: Container(
                  color: Colors.red.withOpacity(
                    0.3 * _nopeOpacityAnimation.value,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _nopeScaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(offer.image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Predicted Fit Badge - ADDED THIS NEW WIDGET
          if (offer.predictedFit != null)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getMatchColor(offer.predictedFit!),
                      _getMatchColor(offer.predictedFit!).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up_alt, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${(offer.predictedFit! * 100).toStringAsFixed(0)}% match',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          offer.logo,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.company.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${offer.experience} • ${offer.location}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  offer.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  offer.description.isNotEmpty
                      ? offer.description
                      : "Join our team and work on exciting projects with cutting-edge technologies.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Required Skills:",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: offer.requiredSkills
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            skill.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 40),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine badge color based on match percentage
  Color _getMatchColor(double predictedFit) {
    if (predictedFit >= 0.8) return Colors.green;
    if (predictedFit >= 0.6) return Colors.lightGreen;
    if (predictedFit >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () => _handleButtonTap(false),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 30),
          ),
        ),
        GestureDetector(
          onTap: () => _handleButtonTap(true),
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF3868), Color(0xFFFF6B8A)],
              ),
            ),
            child: const Icon(
              Icons.thumb_up_alt,
              color: Colors.white,
              size: 35,
            ),
          ),
        ),
        GestureDetector(
          onTap: _showInfoPopup,
          onLongPress: _showExtendedInfo,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
