import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/garden_service.dart';
import '../models/user.dart';
import '../models/visitor_request.dart';
import '../widgets/status_selector.dart';
import '../widgets/visitor_card.dart';
import '../widgets/request_card.dart';

class PandaDashboard extends StatefulWidget {
  const PandaDashboard({Key? key}) : super(key: key);

  @override
  State<PandaDashboard> createState() => _PandaDashboardState();
}

class _PandaDashboardState extends State<PandaDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GardenService>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final gardenService = Provider.of<GardenService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐼 Panda Dashboard'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status', icon: Icon(Icons.home)),
            Tab(text: 'Requests', icon: Icon(Icons.notifications)),
            Tab(text: 'Visitors', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(context, gardenService),
          _buildRequestsTab(context, gardenService),
          _buildVisitorsTab(context, gardenService),
        ],
      ),
    );
  }

  Widget _buildStatusTab(BuildContext context, GardenService gardenService) {
    final pandaUser = gardenService.pandaUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panda Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    '🐼',
                    style: TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pandaUser?.name ?? 'Panda Master',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: Text(
                      pandaUser?.status?.emoji ?? '🏠',
                      style: const TextStyle(fontSize: 18),
                    ),
                    label: Text(
                      pandaUser?.status?.displayName ?? 'Not in Garden',
                      style: const TextStyle(fontSize: 16),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 20),
                  StatusSelector(
                    currentStatus: pandaUser?.status ?? GardenStatus.notInGarden,
                    onStatusChanged: (status) async {
                      await gardenService.updatePandaStatus(status);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Garden Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌳 Garden Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    icon: '👥',
                    label: 'Visitors in Garden',
                    value: gardenService.visitorsInGarden.length.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    icon: '🚶',
                    label: 'Visitors Going',
                    value: gardenService.visitorsGoingToGarden.length.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    icon: '⏳',
                    label: 'Pending Requests',
                    value: gardenService.pendingRequests.length.toString(),
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    icon: '✅',
                    label: 'Approved Visitors',
                    value: gardenService.approvedVisitors.length.toString(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(BuildContext context, GardenService gardenService) {
    final pendingRequests = gardenService.pendingRequests;
    
    if (pendingRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📭',
              style: TextStyle(fontSize: 60),
            ),
            SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return RequestCard(
          request: request,
          onApprove: () async {
            await gardenService.approveRequest(request.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${request.visitorName} approved'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onDeny: () async {
            await gardenService.denyRequest(request.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${request.visitorName} denied'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVisitorsTab(BuildContext context, GardenService gardenService) {
    final visitors = gardenService.visitors;
    
    if (visitors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🚶',
              style: TextStyle(fontSize: 60),
            ),
            SizedBox(height: 16),
            Text(
              'No visitors yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Approved'),
              Tab(text: 'Pending'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Approved visitors
                ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: gardenService.approvedVisitors.length,
                  itemBuilder: (context, index) {
                    final visitor = gardenService.approvedVisitors[index];
                    return VisitorCard(
                      visitor: visitor,
                      onToggleApproval: () async {
                        await gardenService.toggleVisitorApproval(visitor.id);
                      },
                      onUpdateStatus: (status) async {
                        await gardenService.updateVisitorStatus(visitor.id, status);
                      },
                    );
                  },
                ),
                // Unapproved visitors
                ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: gardenService.unapprovedVisitors.length,
                  itemBuilder: (context, index) {
                    final visitor = gardenService.unapprovedVisitors[index];
                    return VisitorCard(
                      visitor: visitor,
                      onToggleApproval: () async {
                        await gardenService.toggleVisitorApproval(visitor.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${visitor.name} approved'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onUpdateStatus: null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
