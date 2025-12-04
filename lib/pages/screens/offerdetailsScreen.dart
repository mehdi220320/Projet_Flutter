import 'package:flutter/material.dart';
import 'package:levelup/models/Offer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:levelup/providers/application_provider.dart';
import 'dart:convert';

class OfferDetailsPage extends StatefulWidget {
  final Offer offer;
  final Function()? onOfferApplied;

  const OfferDetailsPage({super.key, required this.offer, this.onOfferApplied});

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  bool _isApplied = false;
  bool _isDeadlinePassed = false;

  @override
  void initState() {
    super.initState();
    _checkIfApplied();
    _checkDeadline();
  }

  void _checkDeadline() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _isDeadlinePassed = widget.offer.deadline.isBefore(now);
      });
    }
  }

  Future<void> _checkIfApplied() async {
    final prefs = await SharedPreferences.getInstance();
    final appliedOffersJson = prefs.getStringList('applied_offers') ?? [];
    final isApplied = appliedOffersJson.any((jsonString) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return jsonMap['id'] == widget.offer.id;
    });

    if (mounted) {
      setState(() {
        _isApplied = isApplied;
      });
    }
  }

  Future<void> _applyForOffer(BuildContext context) async {
    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );

    _showLoadingDialog(context);

    try {
      await applicationProvider.applyToOffer(widget.offer.id.toString());

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (applicationProvider.error != null) {
        if (mounted) {
          _showErrorDialog(context, applicationProvider.error!);
        }
      } else {
        // Show success with prediction only if still mounted
        if (mounted) {
          _showPredictionDialog(
            context,
            applicationProvider.applicationResult!,
          );
        }

        // Save to shared preferences
        await _saveApplicationToPrefs();

        // Update state only if still mounted
        if (mounted) {
          setState(() {
            _isApplied = true;
          });
        }

        // Notify parent
        widget.onOfferApplied?.call();
      }
    } catch (e) {
      // Close loading dialog and show error only if still mounted
      if (mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, e.toString());
      }
    }
  }

  Future<void> _saveApplicationToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Add to applied offers
    final appliedOffersJson = prefs.getStringList('applied_offers') ?? [];
    final offerJson = json.encode(widget.offer.toJson());

    if (!appliedOffersJson.any((jsonString) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return jsonMap['id'] == widget.offer.id;
    })) {
      appliedOffersJson.add(offerJson);
      await prefs.setStringList('applied_offers', appliedOffersJson);
    }

    // Remove from favorites
    final favoritesJson = prefs.getStringList('favorite_offers') ?? [];
    favoritesJson.removeWhere((jsonString) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return jsonMap['id'] == widget.offer.id;
    });
    await prefs.setStringList('favorite_offers', favoritesJson);
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                "Processing Application...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Please wait while we analyze your profile",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPredictionDialog(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    final predictedFit = result['predicted_fit'] ?? 0.0;
    final percentage = (predictedFit * 100).toStringAsFixed(1);
    final userEmail = result['user'] ?? 'N/A';
    final offerTitle = result['offer'] ?? widget.offer;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Success Title
              const Text(
                "Application Sent!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Offer Title
              Text(
                offerTitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Prediction Circle
              _buildPredictionCircle(predictedFit, percentage),
              const SizedBox(height: 20),

              // User Email
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      color: Colors.blue.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Application sent to:",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
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
      ),
    );
  }

  Widget _buildPredictionCircle(double predictedFit, String percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Circle
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: predictedFit,
            strokeWidth: 8,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPredictionColor(predictedFit),
            ),
          ),
        ),
        // Percentage Text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$percentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getPredictionText(predictedFit),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getPredictionColor(double predictedFit) {
    if (predictedFit >= 0.7) return Colors.green;
    if (predictedFit >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getPredictionText(double predictedFit) {
    if (predictedFit >= 0.7) return "Great Match!";
    if (predictedFit >= 0.5) return "Good Fit";
    return "Needs Review";
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 3),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Application Failed",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Close",
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Offer Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Header Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Badge
                  Stack(
                    children: [
                      _buildCompanyBadge(),
                      // Predicted Fit Badge - ADDED THIS NEW WIDGET
                      if (widget.offer.predictedFit != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getMatchColor(widget.offer.predictedFit!),
                                  _getMatchColor(
                                    widget.offer.predictedFit!,
                                  ).withOpacity(0.8),
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
                                Icon(
                                  Icons.thumb_up_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${(widget.offer.predictedFit! * 100).toStringAsFixed(0)}% match',
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
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Job Title
                  Text(
                    widget.offer.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Job Details Chips
                  _buildJobDetailsChips(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Content Sections
          SliverList(
            delegate: SliverChildListDelegate([
              // About the Role
              _buildSection(
                title: "About the Role",
                icon: Icons.work_outline_rounded,
                content: widget.offer.description,
                color: Colors.blue,
              ),

              // Required Skills
              _buildSkillsSection(),

              // Job Requirements
              _buildRequirementsSection(),

              // Company Details
              _buildCompanySection(),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),

      // Apply Button - Only show if deadline hasn't passed and not already applied
      bottomSheet: _isDeadlinePassed || _isApplied
          ? null
          : _buildApplyButton(context),
    );
  }

  // Helper method to determine badge color based on match percentage
  Color _getMatchColor(double predictedFit) {
    if (predictedFit >= 0.8) return Colors.green;
    if (predictedFit >= 0.6) return Colors.lightGreen;
    if (predictedFit >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCompanyBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Company Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                widget.offer.logo,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer.company.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.offer.company.industry,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white.withOpacity(0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.offer.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Deadline Status
                const SizedBox(height: 6),
                _buildDeadlineStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineStatus() {
    final now = DateTime.now();
    final daysLeft = widget.offer.deadline.difference(now).inDays;

    if (_isDeadlinePassed) {
      return Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.withOpacity(0.8),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            "Application closed",
            style: TextStyle(
              color: Colors.red.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            color: daysLeft <= 3 ? Colors.orange : Colors.green,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            daysLeft == 0
                ? "Apply today!"
                : daysLeft == 1
                ? "1 day left"
                : "$daysLeft days left",
            style: TextStyle(
              color: daysLeft <= 3 ? Colors.orange : Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildJobDetailsChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildDetailChip(
          icon: Icons.work_history_rounded,
          text: widget.offer.experience,
          color: Colors.blue,
        ),
        _buildDetailChip(
          icon: Icons.business_center_rounded,
          text: widget.offer.fieldRequired,
          color: Colors.purple,
        ),
        _buildDetailChip(
          icon: Icons.schedule_rounded,
          text: "Full-time",
          color: Colors.orange,
        ),
        _buildDetailChip(
          icon: Icons.calendar_today_rounded,
          text: "Apply by ${_formatDate(widget.offer.deadline)}",
          color: _isDeadlinePassed ? Colors.red : Colors.green,
        ),
        if (_isDeadlinePassed)
          _buildDetailChip(
            icon: Icons.error_rounded,
            text: "Expired",
            color: Colors.red,
          ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.05), color.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.05),
            Colors.purple.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.code_rounded,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Required Skills",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.offer.requiredSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.2),
                      Colors.blue.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Text(
                  skill.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.05),
            Colors.orange.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Requirements",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._generateRequirements().map(
            (requirement) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle_rounded, color: Colors.orange, size: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      requirement,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateRequirements() {
    return [
      "${widget.offer.experience} of experience in ${widget.offer.fieldRequired}",
      "Proficiency in ${widget.offer.requiredSkills.map((skill) => skill.name).join(', ')}",
      "Strong problem-solving and communication skills",
      "Ability to work in a fast-paced environment",
      "Bachelor's degree in related field preferred",
    ];
  }

  Widget _buildCompanySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.05),
            Colors.green.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Company Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompanyDetailItem(
            icon: Icons.work_rounded,
            title: "Industry",
            value: widget.offer.company.industry,
          ),
          _buildCompanyDetailItem(
            icon: Icons.location_city_rounded,
            title: "Location",
            value:
                "${widget.offer.company.city}, ${widget.offer.company.country}",
          ),
          _buildCompanyDetailItem(
            icon: Icons.language_rounded,
            title: "Website",
            value: widget.offer.company.website,
            isLink: true,
          ),
          _buildCompanyDetailItem(
            icon: Icons.people_rounded,
            title: "Company Size",
            value: "500+ employees",
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: isLink ? () {} : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isLink ? Colors.blue : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isLink ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _applyForOffer(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            shadowColor: Colors.green.withOpacity(0.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Text(
                "Apply Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
}
