import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/garden_service.dart';
import '../models/user.dart';
import '../models/visitor_request.dart';
import '../widgets/status_selector.dart';

class VisitorDashboard extends StatefulWidget {
  const VisitorDashboard({Key? key}) : super(key: key);

  @override
  State<VisitorDashboard> createState() => _VisitorDashboardState();
}

class _VisitorDashboardState extends State<VisitorDashboard> {
  DateTime? _selectedVisitTime;

  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GardenService>(context, listen: false).loadData();
    });
  }

  Future<void> _requestVisit(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final gardenService = Provider.of<GardenService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) return;

    // Show time picker dialog
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selectedDate != null && mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null && mounted) {
        _selectedVisitTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        await gardenService.createVisitorRequest(
          currentUser.id,
          currentUser.name,
          _selectedVisitTime,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Visit request sent to Panda!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final gardenService = Provider.of<GardenService>(context);
    final currentUser = authService.currentUser;
    final pandaUser = gardenService.pandaUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌳 Visitor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gardenService.loadData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await gardenService.loadData();
          await authService.refreshCurrentUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visitor Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '👤',
                        style: TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentUser?.name ?? 'Visitor',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Approval Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (currentUser?.isApproved ?? false)
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              (currentUser?.isApproved ?? false)
                                  ? Icons.check_circle
                                  : Icons.hourglass_empty,
                              color: (currentUser?.isApproved ?? false)
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (currentUser?.isApproved ?? false)
                                  ? 'Approved Visitor'
                                  : 'Pending Approval',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: (currentUser?.isApproved ?? false)
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status selector (only if approved)
                      if (currentUser?.isApproved ?? false) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'My Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Text(
                            currentUser?.status?.emoji ?? '🏠',
                            style: const TextStyle(fontSize: 18),
                          ),
                          label: Text(
                            currentUser?.status?.displayName ?? 'Not in Garden',
                            style: const TextStyle(fontSize: 16),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        StatusSelector(
                          currentStatus: currentUser?.status ?? GardenStatus.notInGarden,
                          onStatusChanged: (status) async {
                            await authService.updateUserStatus(status);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Panda Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '🐼 Panda Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (pandaUser != null) ...[
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _getPandaStatusColor(pandaUser.status),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              pandaUser.status?.emoji ?? '🏠',
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pandaUser.status?.displayName ?? 'Status Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pandaUser.statusUpdatedAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Updated ${_formatTimeAgo(pandaUser.statusUpdatedAt!)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ] else ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text('Loading panda status...'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Request Visit Button (only if approved)
              if (currentUser?.isApproved ?? false)
                ElevatedButton.icon(
                  onPressed: () => _requestVisit(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Request Garden Visit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              
              // Not Approved Message
              if (!(currentUser?.isApproved ?? false)) ...[
                Card(
                  color: Colors.orange.withOpacity(0.1),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 40,
                          color: Colors.orange,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Waiting for Approval',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The Panda needs to approve your account before you can request garden visits or update your status.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 20),
              
              // My Requests History
              FutureBuilder<List<VisitorRequest>>(
                future: gardenService.getVisitorRequests(currentUser?.id ?? ''),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  final requests = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📋 My Request History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...requests.map((request) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDate(request.plannedVisitTime ?? request.requestedAt),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Chip(
                                  avatar: Text(request.status.emoji),
                                  label: Text(request.status.displayName),
                                  backgroundColor: _getRequestStatusColor(request.status),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPandaStatusColor(GardenStatus? status) {
    switch (status) {
      case GardenStatus.inGarden:
        return Colors.green.withOpacity(0.2);
      case GardenStatus.goingToGarden:
        return Colors.blue.withOpacity(0.2);
      case GardenStatus.notInGarden:
      case null:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getRequestStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved:
        return Colors.green.withOpacity(0.2);
      case RequestStatus.denied:
        return Colors.red.withOpacity(0.2);
      case RequestStatus.pending:
        return Colors.orange.withOpacity(0.2);
    }
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
