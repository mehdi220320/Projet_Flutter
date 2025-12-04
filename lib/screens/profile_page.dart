// lib/pages/screens/profile_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:levelup/providers/profile_provider.dart';
import 'package:levelup/providers/auth_provider.dart';
import 'package:levelup/models/profile.dart';
import 'package:levelup/models/user.dart';
import 'package:levelup/models/skill.dart';
import 'package:levelup/models/certification.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch profile when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Set user from auth provider
      if (authProvider.user != null) {
        profileProvider.setUser(authProvider.user!);
      }

      profileProvider.fetchMyProfile();
    });
  }

  void _editProfile() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profileProvider: profileProvider),
    );
  }

  Widget _buildUserInfo(User user) {
    return Container(
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
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Email
          Text(
            user.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          // Username
          Text(
            '@${user.username}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(Profile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field of Study
        _buildInfoCard(
          Icons.school,
          "Field of Study",
          profile.fieldOfStudy.isNotEmpty
              ? profile.fieldOfStudy
              : "Not specified",
          Colors.blue,
        ),
        const SizedBox(height: 16),

        // University Info
        if (profile.university != null)
          Column(
            children: [
              _buildInfoCard(
                Icons.location_city,
                "University",
                profile.university!.name,
                Colors.purple,
              ),
              const SizedBox(height: 16),
            ],
          ),

        // GPA and Score Row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                Icons.grade,
                "GPA",
                profile.gpa.toStringAsFixed(2),
                Colors.green,
                isSmall: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                Icons.leaderboard,
                "Score",
                profile.score.toString(),
                Colors.orange,
                isSmall: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Role
        _buildInfoCard(Icons.person, "Role", profile.role, Colors.cyan),
        const SizedBox(height: 16),

        // Verification Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: profile.isVerified
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: profile.isVerified ? Colors.green : Colors.orange,
            ),
          ),
          child: Row(
            children: [
              Icon(
                profile.isVerified ? Icons.verified : Icons.pending,
                color: profile.isVerified ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                profile.isVerified
                    ? "Account Verified"
                    : "Account Pending Verification",
                style: TextStyle(
                  color: profile.isVerified ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Skills (updated for List<String>)
        _buildSkillsSection(profile.skills),
        const SizedBox(height: 16),

        // Certifications (handle dynamic list)
        _buildCertificationsSection(profile.certifications),
      ],
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    Color color, {
    bool isSmall = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 36 : 40,
            height: isSmall ? 36 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isSmall ? 18 : 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmall ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.code, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Skills",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Text(
              "No skills added yet",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection(List<dynamic> certifications) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Certifications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (certifications.isEmpty)
            Text(
              "No certifications added yet",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: certifications
                  .whereType<String>()
                  .map(
                    (cert) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text(
            "Loading profile...",
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
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          const Text(
            "Error loading profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final profileProvider = Provider.of<ProfileProvider>(
                context,
                listen: false,
              );
              profileProvider.fetchMyProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.loading && profileProvider.profile == null) {
            return _buildLoadingState();
          }

          if (profileProvider.error != null &&
              profileProvider.profile == null) {
            return _buildErrorState(profileProvider.error!);
          }

          return Stack(
            children: [
              // Background Decoration
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header with Edit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Text(
                          "My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _editProfile,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (profileProvider.user != null)
                              _buildUserInfo(profileProvider.user!),

                            const SizedBox(height: 24),

                            // Divider
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            if (profileProvider.profile != null)
                              _buildProfileInfo(profileProvider.profile!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Floating Action Button for Edit
      floatingActionButton: FloatingActionButton(
        onPressed: _editProfile,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final ProfileProvider profileProvider;

  const EditProfileDialog({super.key, required this.profileProvider});

  @override
  EditProfileDialogState createState() => EditProfileDialogState();
}

class EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fieldOfStudyController;
  late TextEditingController _skillController;
  late TextEditingController _universityController;
  late TextEditingController _gpaController;

  List<String> _selectedSkills = [];
  List<String> _selectedCertifications = [];
  bool _initialLoadComplete = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profileProvider.profile;

    _fieldOfStudyController = TextEditingController(
      text: profile?.fieldOfStudy ?? '',
    );
    _skillController = TextEditingController();
    _universityController = TextEditingController(
      text: profile?.university?.name ?? '',
    );
    _gpaController = TextEditingController(
      text: profile?.gpa.toStringAsFixed(2) ?? '0.00',
    );

    _selectedSkills = profile?.skills ?? [];
    _selectedCertifications =
        profile?.certifications?.whereType<String>().toList() ?? [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        widget.profileProvider.fetchAllSkills(),
        widget.profileProvider.fetchAllCertifications(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialLoadComplete = true;
        });
      }
    }
  }

  void _addSkill(String skillName) {
    final trimmedSkill = skillName.trim();
    if (trimmedSkill.isNotEmpty && !_selectedSkills.contains(trimmedSkill)) {
      setState(() {
        _selectedSkills.add(trimmedSkill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skillName) {
    setState(() {
      _selectedSkills.remove(skillName);
    });
  }

  void _toggleCertification(String certName) {
    setState(() {
      if (_selectedCertifications.contains(certName)) {
        _selectedCertifications.remove(certName);
      } else {
        _selectedCertifications.add(certName);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse GPA
        final gpa = double.tryParse(_gpaController.text) ?? 0.0;

        await widget.profileProvider.updateProfile(
          fieldOfStudy: _fieldOfStudyController.text.trim(),
          skills: _selectedSkills,
          certifications: _selectedCertifications,
        );

        if (mounted) {
          Navigator.of(context).pop();
          widget.profileProvider.fetchMyProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            "Loading...",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final availableSkills = widget.profileProvider.allSkills;
    final loadingSkills = widget.profileProvider.loadingSkills;
    final skillsError = widget.profileProvider.skillsError;

    // Show loading only during initial load or if specifically loading skills
    if ((!_initialLoadComplete && _isLoading) || loadingSkills) {
      return _buildLoadingIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Header
        const Row(
          children: [
            Icon(Icons.code, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(
              "Skills",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_selectedSkills.isNotEmpty) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 140),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.5)),
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedSkills
                    .map(
                      (skill) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeSkill(skill),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.purple,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Add Skill Input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _skillController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a skill and press enter...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                ),
                onFieldSubmitted: (value) => _addSkill(value),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _addSkill(_skillController.text),
              ),
            ),
          ],
        ),

        // Available Skills Section
        const SizedBox(height: 12),
        const Text(
          "Available Skills:",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        if (skillsError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Failed to load skills",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () {
                    widget.profileProvider.fetchAllSkills();
                  },
                ),
              ],
            ),
          )
        else if (availableSkills.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSkills
                      .map(
                        (skill) => FilterChip(
                          label: Text(
                            skill.name,
                            style: TextStyle(
                              color: _selectedSkills.contains(skill.name)
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: _selectedSkills.contains(skill.name)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: _selectedSkills.contains(skill.name),
                          onSelected: (selected) {
                            if (selected) {
                              _addSkill(skill.name);
                            } else {
                              _removeSkill(skill.name);
                            }
                          },
                          backgroundColor: _selectedSkills.contains(skill.name)
                              ? Colors.purple
                              : Colors.grey.shade300,
                          selectedColor: Colors.purple,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
        else if (!_initialLoadComplete)
          _buildLoadingIndicator()
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: Text(
                "No skills available",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    final availableCertifications = widget.profileProvider.allCertifications;
    final loadingCertifications = widget.profileProvider.loadingCertifications;
    final certificationsError = widget.profileProvider.certificationsError;

    // Show loading only during initial load or if specifically loading certifications
    if ((!_initialLoadComplete && _isLoading) || loadingCertifications) {
      return _buildLoadingIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certifications Header
        const Row(
          children: [
            Icon(Icons.verified, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text(
              "Certifications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (certificationsError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Failed to load certifications",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: () {
                    widget.profileProvider.fetchAllCertifications();
                  },
                ),
              ],
            ),
          )
        else if (availableCertifications.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: availableCertifications.length,
              itemBuilder: (context, index) {
                final cert = availableCertifications[index];
                final certName =
                    cert.name; // Assuming Certification has a name property

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedCertifications.contains(certName)
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCertifications.contains(certName)
                          ? Colors.amber
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      certName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: _selectedCertifications.contains(certName)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: cert.issuer.isNotEmpty
                        ? Text(
                            "Issuer: ${cert.issuer}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    value: _selectedCertifications.contains(certName),
                    onChanged: (selected) => _toggleCertification(certName),
                    activeColor: Colors.amber,
                    checkColor: Colors.black,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                );
              },
            ),
          )
        else if (!_initialLoadComplete)
          _buildLoadingIndicator()
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: Text(
                "No certifications available",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Field of Study
                        TextFormField(
                          controller: _fieldOfStudyController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Field of Study",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your field of study';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // GPA
                        TextFormField(
                          controller: _gpaController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: "GPA",
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your GPA';
                            }
                            final gpa = double.tryParse(value);
                            if (gpa == null || gpa < 0 || gpa > 4.0) {
                              return 'Please enter a valid GPA (0.0 - 4.0)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Skills Section
                        _buildSkillsSection(),
                        const SizedBox(height: 24),

                        // Certifications Section
                        _buildCertificationsSection(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Buttons (fixed at bottom)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: widget.profileProvider.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fieldOfStudyController.dispose();
    _skillController.dispose();
    _universityController.dispose();
    _gpaController.dispose();
    super.dispose();
  }
}
