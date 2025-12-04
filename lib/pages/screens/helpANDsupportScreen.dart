import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Help & Support",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Everything you need to know about LevelUp",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              // About LevelUp Section
              _buildSection(
                icon: Icons.rocket_launch,
                title: "What is LevelUp?",
                content:
                    "LevelUp is an intelligent mobile recruitment application designed specifically for students. Our platform uses AI to match your profile with the most relevant job offers.",
                color: Colors.blue,
              ),

              const SizedBox(height: 24),

              // How to Use Section
              _buildSection(
                icon: Icons.swipe,
                title: "How to Use the App",
                content: "Our application consists of 4 main sections:",
                color: Colors.purple,
                children: [
                  _buildStep(
                    number: "1",
                    title: "Swipe Offers",
                    description:
                        "On the home page, swipe right to like an offer or left to skip. Each offer shows your match percentage.",
                  ),
                  _buildStep(
                    number: "2",
                    title: "Favorites",
                    description:
                        "Find all the offers you've liked in the Favorites tab. You can review them and apply later.",
                  ),
                  _buildStep(
                    number: "3",
                    title: "Apply",
                    description:
                        "Click on an offer to see complete details. Use the 'Apply' button to submit your application.",
                  ),
                  _buildStep(
                    number: "4",
                    title: "History",
                    description:
                        "Track all your applications in the History tab. Receive feedback from recruiters directly here.",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Matching Algorithm Section
              _buildSection(
                icon: Icons.psychology,
                title: "How Does Matching Work?",
                content:
                    "Our algorithm analyzes several criteria to calculate your compatibility with each offer:",
                color: Colors.green,
                children: [
                  _buildCriteriaItem("Skills and mastered technologies"),
                  _buildCriteriaItem("Certifications and training"),
                  _buildCriteriaItem("Field of study"),
                  _buildCriteriaItem("Experience level"),
                  _buildCriteriaItem("Location and work type"),
                ],
              ),

              const SizedBox(height: 24),

              // Tips Section
              _buildSection(
                icon: Icons.lightbulb,
                title: "Tips for Success",
                content: "Maximize your matching chances:",
                color: Colors.orange,
                children: [
                  _buildTipItem("Complete your profile to 100%"),
                  _buildTipItem("Add all your skills"),
                  _buildTipItem("Update your certifications"),
                  _buildTipItem("Swipe regularly for more opportunities"),
                  _buildTipItem("Apply quickly to offers that interest you"),
                ],
              ),

              const SizedBox(height: 24),

              // Support Section
              _buildSection(
                icon: Icons.support_agent,
                title: "Technical Support",
                content: "Need additional help?",
                color: Colors.red,
                children: [
                  _buildSupportItem(
                    Icons.email,
                    "Email Support",
                    "support@levelup.com",
                  ),
                  _buildSupportItem(
                    Icons.help_center,
                    "FAQ",
                    "Frequently asked questions",
                  ),
                  _buildSupportItem(
                    Icons.bug_report,
                    "Report a Problem",
                    "Contact us for bugs",
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade800.withOpacity(0.8),
                      Colors.purple.shade800.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      "LevelUp",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your intelligent recruitment partner",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Find the perfect opportunity that matches your profile",
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    List<Widget>? children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          // Children if any
          if (children != null) ...[const SizedBox(height: 16), ...children],
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(String criteria) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              criteria,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }
}
