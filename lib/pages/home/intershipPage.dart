import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:levelup/models/internship_demand.dart';
import 'package:levelup/providers/internship_demand_provider.dart';

class InternshipDemandsPage extends StatelessWidget {
  const InternshipDemandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InternshipDemandProvider(),
      child: const _InternshipDemandsPageContent(),
    );
  }
}

class _InternshipDemandsPageContent extends StatefulWidget {
  const _InternshipDemandsPageContent({super.key});

  @override
  State<_InternshipDemandsPageContent> createState() =>
      _InternshipDemandsPageState();
}

class _InternshipDemandsPageState extends State<_InternshipDemandsPageContent> {
  String _selectedFilter = 'all';
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _applicationIdController =
      TextEditingController();
  final TextEditingController _offerTitleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternshipDemandProvider>(
        context,
        listen: false,
      ).fetchMyDemands();
    });
  }

  @override
  void dispose() {
    _universityController.dispose();
    _applicationIdController.dispose();
    _offerTitleController.dispose();
    super.dispose();
  }

  List<InternshipDemand> _getFilteredDemands(
    InternshipDemandProvider provider,
  ) {
    final allDemands = provider.sortedByDate;

    switch (_selectedFilter) {
      case 'pending':
        return allDemands
            .where((demand) => demand.status.toLowerCase() == 'pending')
            .toList();
      case 'approved':
        return allDemands
            .where((demand) => demand.status.toLowerCase() == 'approved')
            .toList();
      case 'rejected':
        return allDemands
            .where((demand) => demand.status.toLowerCase() == 'rejected')
            .toList();
      case 'all':
      default:
        return allDemands;
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'all':
      default:
        return 'All Demands';
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'all':
      default:
        return Colors.blue;
    }
  }

  void _showCreateDemandDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Internship Demand",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _universityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'University',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your university';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _applicationIdController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Application ID',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter application ID';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _offerTitleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Internship Position',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the internship position';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success =
                                await Provider.of<InternshipDemandProvider>(
                                  context,
                                  listen: false,
                                ).createDemand(
                                  university: _universityController.text,
                                  applicationId: int.parse(
                                    _applicationIdController.text,
                                  ),
                                  offerTitle: _offerTitleController.text,
                                );

                            if (success) {
                              _universityController.clear();
                              _applicationIdController.clear();
                              _offerTitleController.clear();

                              Navigator.of(context).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Internship demand created successfully!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              final error =
                                  Provider.of<InternshipDemandProvider>(
                                    context,
                                    listen: false,
                                  ).error;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error creating demand: $error',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Create",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDocumentGeneratedAlert(
    BuildContext context,
    InternshipDemand demand,
    String documentType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "$documentType Generated",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.email,
              size: 60,
              color: documentType == 'Convention' ? Colors.blue : Colors.purple,
            ),
            const SizedBox(height: 20),
            Text(
              "$documentType has been generated successfully!",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "The $documentType has been sent to your email:",
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 5),
            Text(
              demand.student,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: documentType == 'Convention'
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: documentType == 'Convention'
                      ? Colors.blue
                      : Colors.purple,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check your email for:",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "• $documentType document (PDF)",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  Text(
                    "• Download link",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  Text(
                    "• Instructions for next steps",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
              // TODO: Open email app
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: documentType == 'Convention'
                  ? Colors.blue
                  : Colors.purple,
            ),
            child: const Text(
              "Open Email",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAttestationRequest(InternshipDemand demand) async {
    final success = await Provider.of<InternshipDemandProvider>(
      context,
      listen: false,
    ).requestAttestation(demand.id);

    if (success) {
      _showDocumentGeneratedAlert(context, demand, "Attestation");
    } else {
      final error = Provider.of<InternshipDemandProvider>(
        context,
        listen: false,
      ).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error requesting attestation: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGenerateConvention(InternshipDemand demand) async {
    final success = await Provider.of<InternshipDemandProvider>(
      context,
      listen: false,
    ).generateConvention(demand.id);

    if (success) {
      _showDocumentGeneratedAlert(context, demand, "Convention");
    } else {
      final error = Provider.of<InternshipDemandProvider>(
        context,
        listen: false,
      ).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error generating convention: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGenerateLetter(InternshipDemand demand) async {
    final success = await Provider.of<InternshipDemandProvider>(
      context,
      listen: false,
    ).generateLetter(demand.id);

    if (success) {
      _showDocumentGeneratedAlert(context, demand, "Letter");
    } else {
      final error = Provider.of<InternshipDemandProvider>(
        context,
        listen: false,
      ).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error generating letter: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDemandDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<InternshipDemandProvider>(
        builder: (context, demandProvider, child) {
          if (demandProvider.loading && demandProvider.demands.isEmpty) {
            return _buildLoadingState();
          }

          if (demandProvider.error != null) {
            return _buildErrorState(context, demandProvider.error!);
          }

          final demands = _getFilteredDemands(demandProvider);

          if (demands.isEmpty) {
            return _buildEmptyState(context, _selectedFilter);
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  "Internship Demands",
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
              SliverToBoxAdapter(child: _buildStatsSection(demandProvider)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final demand = demands[index];
                  return _buildDemandCard(demand);
                }, childCount: demands.length),
              ),
              // Load more indicator
              if (demandProvider.hasMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: demandProvider.loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : ElevatedButton(
                              onPressed: () {
                                Provider.of<InternshipDemandProvider>(
                                  context,
                                  listen: false,
                                ).loadMoreDemands();
                              },
                              child: const Text('Load More'),
                            ),
                    ),
                  ),
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
            "Loading internship demands...",
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
            "Error loading demands",
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
              Provider.of<InternshipDemandProvider>(
                context,
                listen: false,
              ).fetchMyDemands();
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
        message = "No Pending Demands";
        subMessage =
            "You don't have any internship demands waiting for approval";
        break;
      case 'approved':
        message = "No Approved Demands";
        subMessage = "You don't have any approved internship demands yet";
        break;
      case 'rejected':
        message = "No Rejected Demands";
        subMessage = "Great! None of your demands have been rejected";
        break;
      case 'all':
      default:
        message = "No Demands Yet";
        subMessage = "Create your first internship demand to get started";
        break;
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showCreateDemandDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Create Demand",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(InternshipDemandProvider provider) {
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
            provider.demands.length.toString(),
            Icons.assignment_outlined,
            Colors.blue,
          ),
          _buildStatItem(
            "Pending",
            provider.pendingDemands.length.toString(),
            Icons.pending,
            Colors.orange,
          ),
          _buildStatItem(
            "Approved",
            provider.approvedDemands.length.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatItem(
            "Rejected",
            provider.rejectedDemands.length.toString(),
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

  Widget _buildDemandCard(InternshipDemand demand) {
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
                child: const Center(
                  child: Icon(Icons.school, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demand.university,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      demand.offerTitle,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: demand.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: demand.statusColor),
                ),
                child: Text(
                  demand.statusText,
                  style: TextStyle(
                    color: demand.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.numbers, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      "App #${demand.application}",
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
              const Icon(Icons.calendar_today, color: Colors.white60, size: 14),
              const SizedBox(width: 4),
              Text(
                demand.formattedCreatedAt,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              if (demand.reviewedAt != null)
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.white60, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      demand.formattedReviewedAt,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.white54, size: 12),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  demand.student,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons for approved demands
          if (demand.status.toLowerCase() == 'approved')
            Column(
              children: [
                // Row with two buttons
                Row(
                  children: [
                    // Convention Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _handleGenerateConvention(demand),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.description, size: 16),
                          label: const Text(
                            "Generate Convention",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Letter Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade600,
                              Colors.purple.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _handleGenerateLetter(demand),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.mail_outline, size: 16),
                          label: const Text(
                            "Generate Letter",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                "Filter Demands",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                context,
                "All Demands",
                Icons.all_inclusive,
                'all',
              ),
              _buildFilterOption(context, "Pending", Icons.pending, 'pending'),
              _buildFilterOption(
                context,
                "Approved",
                Icons.check_circle,
                'approved',
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
