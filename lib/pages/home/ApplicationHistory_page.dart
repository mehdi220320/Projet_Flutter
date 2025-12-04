import 'package:flutter/material.dart';
import 'package:levelup/models/internship_demand.dart';
import 'package:levelup/pages/home/home.dart';
import 'package:provider/provider.dart';
import 'package:levelup/models/application.dart';
import 'package:levelup/providers/application_provider.dart';
import 'package:levelup/providers/internship_demand_provider.dart';
import 'package:levelup/pages/home/intershipPage.dart';

class ApplicationHistoryPage extends StatefulWidget {
  const ApplicationHistoryPage({super.key});

  @override
  State<ApplicationHistoryPage> createState() => _ApplicationHistoryPageState();
}

class _ApplicationHistoryPageState extends State<ApplicationHistoryPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(
        context,
        listen: false,
      ).fetchMyApplications();

      Provider.of<InternshipDemandProvider>(
        context,
        listen: false,
      ).fetchMyDemands();
    });
  }

  List<Application> _getFilteredApplications(ApplicationProvider provider) {
    final allApplications = provider.sortedByDate;

    switch (_selectedFilter) {
      case 'pending':
        return allApplications
            .where((app) => app.status.toLowerCase() == 'pending')
            .toList();
      case 'accepted':
        return allApplications
            .where((app) => app.status.toLowerCase() == 'accepted')
            .toList();
      case 'rejected':
        return allApplications
            .where((app) => app.status.toLowerCase() == 'rejected')
            .toList();
      case 'all':
      default:
        return allApplications;
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'all':
      default:
        return 'All Applications';
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'all':
      default:
        return Colors.blue;
    }
  }

  void _showCreateDemandDialog(BuildContext context, Application application) {
    final demandProvider = Provider.of<InternshipDemandProvider>(
      context,
      listen: false,
    );

    // Check if demand already exists
    if (demandProvider.demandExistsForApplication(application.id)) {
      final existingDemand = demandProvider.getDemandByApplicationId(
        application.id,
      );
      _showDemandExistsAlert(context, existingDemand!);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),

              const Text(
                "Create Internship Demand",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                application.offer.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                application.offer.company.name,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "What happens next?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your university will be notified and will review your request. "
                      "Once approved, you can request an internship attestation.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                      onPressed: () async {
                        Navigator.of(context).pop();

                        final success = await demandProvider.createSimpleDemand(
                          applicationId: application.id,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Internship demand created successfully!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );

                          // Optionally navigate to internship demands page
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: demandProvider,
                                      child: const InternshipDemandsPage(),
                                    ),
                              ),
                            );
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${demandProvider.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Create Demand",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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

  void _showDemandExistsAlert(BuildContext context, InternshipDemand demand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Demand Already Exists",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You already have an internship demand for this application.",
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: demand.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: demand.statusColor),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDemandStatusIcon(demand.status),
                    color: demand.statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status: ${demand.statusText}",
                          style: TextStyle(
                            color: demand.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Created: ${demand.formattedCreatedAt}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: Provider.of<InternshipDemandProvider>(
                      context,
                      listen: false,
                    ),
                    child: const InternshipDemandsPage(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              "View Demand",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDemandStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildDemandButton(Application application, BuildContext context) {
    final demandProvider = Provider.of<InternshipDemandProvider>(
      context,
      listen: false,
    );

    final existingDemand = demandProvider.getDemandByApplicationId(
      application.id,
    );

    if (existingDemand != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: existingDemand.statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: existingDemand.statusColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getDemandStatusIcon(existingDemand.status),
              color: existingDemand.statusColor,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              existingDemand.statusText,
              style: TextStyle(
                color: existingDemand.statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showCreateDemandDialog(context, application),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, size: 14),
            const SizedBox(width: 6),
            Text(
              "Internship Demand",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ApplicationProvider>(
        builder: (context, applicationProvider, child) {
          if (applicationProvider.loading &&
              applicationProvider.applications.isEmpty) {
            return _buildLoadingState();
          }

          if (applicationProvider.error != null) {
            return _buildErrorState(context, applicationProvider.error!);
          }

          final applications = _getFilteredApplications(applicationProvider);

          if (applications.isEmpty) {
            return _buildEmptyState(context, _selectedFilter);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  "My Applications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                actions: [
                  if (_selectedFilter != 'all')
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getFilterColor(
                          _selectedFilter,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getFilterColor(_selectedFilter),
                        ),
                      ),
                      child: Text(
                        _getFilterDisplayName(_selectedFilter),
                        style: TextStyle(
                          color: _getFilterColor(_selectedFilter),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      Provider.of<ApplicationProvider>(
                        context,
                        listen: false,
                      ).refreshApplications();
                      Provider.of<InternshipDemandProvider>(
                        context,
                        listen: false,
                      ).refreshDemands();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () => _showFilterDialog(context),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: _buildStatsSection(applicationProvider),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final application = applications[index];
                  return _buildApplicationCard(application);
                }, childCount: applications.length),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            "Loading applications...",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          const Text(
            "Error loading applications",
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
              Provider.of<ApplicationProvider>(
                context,
                listen: false,
              ).fetchMyApplications();
            },
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String filter) {
    String message;
    String subMessage;

    switch (filter) {
      case 'pending':
        message = "No Pending Applications";
        subMessage = "You don't have any applications waiting for review";
        break;
      case 'accepted':
        message = "No Accepted Applications";
        subMessage = "You haven't been accepted to any positions yet";
        break;
      case 'rejected':
        message = "No Rejected Applications";
        subMessage = "Great! You haven't been rejected from any positions";
        break;
      case 'all':
      default:
        message = "No Applications Yet";
        subMessage = "Start applying to jobs to see your history here";
        break;
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (filter != 'all')
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'all';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "View All Applications",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "Browse Jobs",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ApplicationProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "Total",
            provider.applications.length.toString(),
            Icons.work_outline,
            Colors.blue,
          ),
          _buildStatItem(
            "Pending",
            provider.pendingApplications.length.toString(),
            Icons.pending,
            Colors.orange,
          ),
          _buildStatItem(
            "Accepted",
            provider.acceptedApplications.length.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatItem(
            "Rejected",
            provider.rejectedApplications.length.toString(),
            Icons.cancel,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildApplicationCard(Application application) {
    final companyName = application.offer.company.name;
    final appID = application.id;
    final jobTitle = application.offer.title;
    final location = application.offer.location;
    final experience = application.offer.experience;
    final skills = application.offer.requiredSkills;
    final logo = application.offer.logo;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    logo.isNotEmpty ? logo : '🏢',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "#${appID.toString()} ${companyName.isNotEmpty ? companyName : 'Unknown Company'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      jobTitle.isNotEmpty ? jobTitle : 'Unknown Position',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: application.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: application.statusColor),
                ),
                child: Text(
                  application.statusText,
                  style: TextStyle(
                    color: application.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Match percentage and location
          Row(
            children: [
              // Match percentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      application.predictedFitColor,
                      application.predictedFitColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.predictedFitPercentage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Location
              const Icon(Icons.location_on, color: Colors.white60, size: 14),
              const SizedBox(width: 4),
              Text(
                location.isNotEmpty ? location : 'Remote',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              // Experience
              const Icon(Icons.work_history, color: Colors.white60, size: 14),
              const SizedBox(width: 4),
              Text(
                experience.isNotEmpty ? experience : 'Not specified',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skills
          if (skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: skills.take(3).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    skill.name.isNotEmpty ? skill.name : 'Skill',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          // Applied date and demand button (for accepted applications)
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 12),
              const SizedBox(width: 6),
              Text(
                "Applied recently",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              // Show demand button only for accepted applications
              if (application.status.toLowerCase() == 'accepted')
                Consumer<InternshipDemandProvider>(
                  builder: (context, demandProvider, child) {
                    return _buildDemandButton(application, context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filter Applications",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                context,
                "All Applications",
                Icons.all_inclusive,
                'all',
              ),
              _buildFilterOption(context, "Pending", Icons.pending, 'pending'),
              _buildFilterOption(
                context,
                "Accepted",
                Icons.check_circle,
                'accepted',
              ),
              _buildFilterOption(context, "Rejected", Icons.cancel, 'rejected'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    IconData icon,
    String filter,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedFilter == filter
            ? _getFilterColor(filter)
            : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedFilter == filter
              ? _getFilterColor(filter)
              : Colors.white,
          fontWeight: _selectedFilter == filter
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      trailing: _selectedFilter == filter
          ? Icon(Icons.check, color: _getFilterColor(filter))
          : null,
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        Navigator.of(context).pop();
      },
    );
  }
}
