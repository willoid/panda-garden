import 'package:flutter/material.dart';
import '../models/user.dart';

class VisitorCard extends StatelessWidget {
  final User visitor;
  final VoidCallback? onToggleApproval;
  final Function(GardenStatus)? onUpdateStatus;

  const VisitorCard({
    Key? key,
    required this.visitor,
    this.onToggleApproval,
    this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: visitor.isApproved 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                child: Text(
                  '👤',
                  style: TextStyle(
                    fontSize: 24,
                    color: visitor.isApproved ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              title: Text(
                visitor.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(visitor.email),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        visitor.isApproved 
                            ? Icons.check_circle 
                            : Icons.hourglass_empty,
                        size: 16,
                        color: visitor.isApproved ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        visitor.isApproved ? 'Approved' : 'Pending',
                        style: TextStyle(
                          color: visitor.isApproved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: onToggleApproval != null
                  ? IconButton(
                      icon: Icon(
                        visitor.isApproved 
                            ? Icons.person_remove 
                            : Icons.person_add,
                        color: visitor.isApproved ? Colors.red : Colors.green,
                      ),
                      onPressed: onToggleApproval,
                    )
                  : null,
            ),
            
            if (visitor.isApproved && visitor.status != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      avatar: Text(
                        visitor.status!.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      label: Text(visitor.status!.displayName),
                      backgroundColor: _getStatusColor(visitor.status!),
                    ),
                  ],
                ),
              ),
              
              if (onUpdateStatus != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: GardenStatus.values.map((status) {
                      return ActionChip(
                        avatar: Text(status.emoji),
                        label: Text(
                          status == GardenStatus.notInGarden ? 'Not' 
                              : status == GardenStatus.goingToGarden ? 'Going'
                              : 'In',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: status == visitor.status
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        labelStyle: TextStyle(
                          color: status == visitor.status
                              ? Colors.white
                              : null,
                        ),
                        onPressed: status == visitor.status
                            ? null
                            : () => onUpdateStatus!(status),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
            
            if (visitor.statusUpdatedAt != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Last updated: ${_formatTime(visitor.statusUpdatedAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(GardenStatus status) {
    switch (status) {
      case GardenStatus.inGarden:
        return Colors.green.withOpacity(0.2);
      case GardenStatus.goingToGarden:
        return Colors.blue.withOpacity(0.2);
      case GardenStatus.notInGarden:
        return Colors.grey.withOpacity(0.2);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
