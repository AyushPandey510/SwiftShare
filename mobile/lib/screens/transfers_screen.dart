import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftshare_mobile/providers/transfer_provider.dart';
import 'package:swiftshare_mobile/utils/theme.dart';
import 'package:intl/intl.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Failed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransfersList(context, null),
          _buildTransfersList(context, TransferStatus.completed),
          _buildTransfersList(context, TransferStatus.failed),
        ],
      ),
    );
  }

  Widget _buildTransfersList(BuildContext context, TransferStatus? filterStatus) {
    return Consumer<TransferProvider>(
      builder: (context, transferProvider, child) {
        List<TransferItem> transfers;
        
        if (filterStatus == null) {
          transfers = transferProvider.transfers;
        } else {
          transfers = transferProvider.transfers
              .where((t) => t.status == filterStatus)
              .toList();
        }

        if (transfers.isEmpty) {
          return _buildEmptyState(context, filterStatus);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transfers.length,
          itemBuilder: (context, index) {
            final transfer = transfers[index];
            return _TransferCard(
              transfer: transfer,
              transferProvider: transferProvider,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TransferStatus? filterStatus) {
    String title;
    String message;
    IconData icon;

    switch (filterStatus) {
      case TransferStatus.completed:
        title = 'No completed transfers';
        message = 'Completed transfers will appear here';
        icon = Icons.check_circle_outline;
        break;
      case TransferStatus.failed:
        title = 'No failed transfers';
        message = 'Failed transfers will appear here';
        icon = Icons.error_outline;
        break;
      default:
        title = 'No transfers yet';
        message = 'Start sharing files to see your transfer history';
        icon = Icons.history;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body2.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferCard extends StatelessWidget {
  final TransferItem transfer;
  final TransferProvider transferProvider;

  const _TransferCard({
    required this.transfer,
    required this.transferProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getStatusIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.fileName,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'To: ${transfer.targetDevice}',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _getStatusBadge(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(transfer.startTime),
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  transferProvider.formatFileSize(transfer.fileSize),
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (transfer.status == TransferStatus.inProgress) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: transfer.progress,
                backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(transfer.progress * 100).toInt()}%',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    transferProvider.formatSpeed(transfer.speed),
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
            if (transfer.status == TransferStatus.completed && transfer.endTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed ${_formatDateTime(transfer.endTime!)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon() {
    IconData icon;
    Color color;

    switch (transfer.status) {
      case TransferStatus.pending:
        icon = Icons.schedule;
        color = AppColors.warning;
        break;
      case TransferStatus.inProgress:
        icon = Icons.sync;
        color = AppColors.primary;
        break;
      case TransferStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case TransferStatus.failed:
        icon = Icons.error;
        color = AppColors.error;
        break;
      case TransferStatus.cancelled:
        icon = Icons.cancel;
        color = AppColors.error;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _getStatusBadge() {
    String text;
    Color color;

    switch (transfer.status) {
      case TransferStatus.pending:
        text = 'Pending';
        color = AppColors.warning;
        break;
      case TransferStatus.inProgress:
        text = 'In Progress';
        color = AppColors.primary;
        break;
      case TransferStatus.completed:
        text = 'Completed';
        color = AppColors.success;
        break;
      case TransferStatus.failed:
        text = 'Failed';
        color = AppColors.error;
        break;
      case TransferStatus.cancelled:
        text = 'Cancelled';
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 