import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/garden_service.dart';
import '../models/user.dart';
import '../widgets/status_selector.dart';

class VisitorDashboard extends StatefulWidget {
  const VisitorDashboard({Key? key}) : super(key: key);

  @override
  State<VisitorDashboard> createState() => _VisitorDashboardState();
}

class _VisitorDashboardState extends State<VisitorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GardenService>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final gardenService = Provider.of<GardenService>(context);
    final currentUser = authService.currentUser;
    final pandaUser = gardenService.pandaUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('👤 ${currentUser?.name ?? 'Visitor'}'),
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
              // Panda Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getPandaStatusColor(pandaUser?.status),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            pandaUser?.status?.emoji ?? '🏠',
                            style: const TextStyle(fontSize: 35),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getPandaStatusMessage(pandaUser?.status),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (pandaUser?.status == GardenStatus.goingToGarden ||
                  pandaUser?.status == GardenStatus.inGarden) ...[
                const SizedBox(height: 20),

                ..._buildVisitorsList(gardenService, currentUser?.id),

                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Chip(
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
                        ),
                        const SizedBox(height: 16),
                        StatusSelector(
                          currentStatus: currentUser?.status ?? GardenStatus.notInGarden,
                          onStatusChanged: (status) async {
                            await _changeStatus(status);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVisitorsList(GardenService gardenService, String? currentUserId) {
    final activeVisitors = gardenService.visitors.where((v) {
      return v.id != currentUserId &&
          (v.status == GardenStatus.goingToGarden ||
              v.status == GardenStatus.inGarden);
    }).toList();

    if (activeVisitors.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.people_outline, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  'No other visitors yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.people, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Other Visitors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...activeVisitors.map((visitor) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      visitor.status!.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getVisitorStatusText(visitor),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    ];
  }

  String _getVisitorStatusText(User visitor) {
    if (visitor.status == GardenStatus.inGarden) {
      return '${visitor.name} is in the garden';
    } else if (visitor.status == GardenStatus.goingToGarden) {
      return '${visitor.name} is going to the garden';
    }
    return visitor.name;
  }

  String _getPandaStatusMessage(GardenStatus? status) {
    switch (status) {
      case GardenStatus.inGarden:
        return 'The panda is in the garden';
      case GardenStatus.goingToGarden:
        return 'The panda is going to the garden';
      case GardenStatus.notInGarden:
      case null:
        return 'The panda is not in the garden';
    }
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

  Future<void> _changeStatus(GardenStatus newStatus) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final gardenService = Provider.of<GardenService>(context, listen: false);

    await authService.updateUserStatus(newStatus);
    await gardenService.loadData(); // Refresh to update the visitors list

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Status changed to ${newStatus.displayName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}