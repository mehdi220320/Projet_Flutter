import 'package:flutter/material.dart';
import 'package:levelup/models/Offer.dart';
import 'package:levelup/pages/screens/offerdetailsScreen.dart';

class FavoritesPage extends StatelessWidget {
  final List<Offer> favoriteOffers;
  final Function(List<Offer>) onFavoritesUpdated;
  final Function()? onRefreshFavorites;

  const FavoritesPage({
    super.key,
    required this.favoriteOffers,
    required this.onFavoritesUpdated,
    this.onRefreshFavorites,
  });

  void _removeFromFavorites(int index, BuildContext context) {
    final updatedFavorites = List<Offer>.from(favoriteOffers);
    updatedFavorites.removeAt(index);
    onFavoritesUpdated(updatedFavorites);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showOfferDetails(Offer offer, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OfferDetailsPage(
          offer: offer,
          onOfferApplied: () {
            final updatedFavorites = favoriteOffers
                .where((fav) => fav.id != offer.id)
                .toList();
            onFavoritesUpdated(updatedFavorites);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Successfully applied for ${offer.title}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteOfferCard(Offer offer, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _showOfferDetails(offer, context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(offer.logo, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 15),

            // Offer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company and Title
                  Text(
                    offer.company.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Experience and Location
                  Text(
                    "${offer.experience} • ${offer.location}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Required Skills
                  if (offer.requiredSkills.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: offer.requiredSkills
                          .take(3)
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                skill.name,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  // Deadline
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white.withOpacity(0.6),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Apply before ${_formatDate(offer.deadline)}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              onPressed: () => _removeFromFavorites(index, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 50,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "No Favorites Yet",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "Swipe right on jobs you like to add them here!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Swipe Right to Like",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Liked jobs will appear here for easy access",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (favoriteOffers.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Favorite Jobs",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${favoriteOffers.length} saved ${favoriteOffers.length == 1 ? 'job' : 'jobs'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRefreshFavorites != null)
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: onRefreshFavorites,
                    tooltip: "Refresh favorites",
                  ),
              ],
            ),
          ),

          // Favorites List
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Colors.black,
              color: Colors.white,
              onRefresh: () async {
                if (onRefreshFavorites != null) {
                  onRefreshFavorites!();
                }
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteOffers.length,
                itemBuilder: (context, index) {
                  final offer = favoriteOffers[index];
                  return _buildFavoriteOfferCard(offer, index, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
