import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/report_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/app_constants.dart';

/// Government review screen for citizen complaints & transparency reports.
/// Allows officials to inspect evidence, attach official remedial findings,
/// and update report status (under review, resolved, or rejected).
class GovCitizenReportsScreen extends StatefulWidget {
  const GovCitizenReportsScreen({super.key});

  @override
  State<GovCitizenReportsScreen> createState() => _GovCitizenReportsScreenState();
}

class _GovCitizenReportsScreenState extends State<GovCitizenReportsScreen> {
  String? _currentFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadReports(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Citizen Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportProvider>().loadReports(refresh: true),
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reports.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No citizen reports in this queue'),
                  if (_currentFilter != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() => _currentFilter = null);
                        provider.loadReports(refresh: true);
                      },
                      child: const Text('Reset Filter'),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadReports(refresh: true),
            child: Column(
              children: [
                // Summary metric badges
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatusCountBadge(
                        label: 'Submitted',
                        count: provider.pendingReports,
                        color: Colors.orange,
                        isSelected: _currentFilter == 'submitted',
                        onTap: () => _applyQuickFilter('submitted'),
                      ),
                      _StatusCountBadge(
                        label: 'Under Review',
                        count: provider.underReviewReports,
                        color: Colors.blue,
                        isSelected: _currentFilter == 'underReview',
                        onTap: () => _applyQuickFilter('underReview'),
                      ),
                      _StatusCountBadge(
                        label: 'Resolved',
                        count: provider.resolvedReports,
                        color: Colors.green,
                        isSelected: _currentFilter == 'resolved',
                        onTap: () => _applyQuickFilter('resolved'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.reports.length,
                    itemBuilder: (context, index) {
                      final report = provider.reports[index];
                      return _ReportCard(
                        report: report,
                        onAction: (status) => _showResolutionDialog(context, report, status),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _applyQuickFilter(String status) {
    if (_currentFilter == status) {
      setState(() => _currentFilter = null);
      context.read<ReportProvider>().loadReports(refresh: true);
    } else {
      setState(() => _currentFilter = status);
      context.read<ReportProvider>().filterByStatus(status);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Filter Reports', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inbox),
              title: const Text('Show All'),
              onTap: () {
                setState(() => _currentFilter = null);
                context.read<ReportProvider>().loadReports(refresh: true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.orange),
              title: const Text('Submitted (Pending)'),
              onTap: () {
                setState(() => _currentFilter = 'submitted');
                context.read<ReportProvider>().filterByStatus('submitted');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.blue),
              title: const Text('Under Review'),
              onTap: () {
                setState(() => _currentFilter = 'underReview');
                context.read<ReportProvider>().filterByStatus('underReview');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.green),
              title: const Text('Resolved'),
              onTap: () {
                setState(() => _currentFilter = 'resolved');
                context.read<ReportProvider>().filterByStatus('resolved');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResolutionDialog(
    BuildContext context,
    CitizenReport report,
    ReportStatus targetStatus,
  ) {
    final responseController = TextEditingController();
    final actionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final actionLabel = targetStatus == ReportStatus.resolved
        ? 'Resolve Report'
        : (targetStatus == ReportStatus.underReview ? 'Move to Review' : 'Reject Report');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(actionLabel),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Case: ${report.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: responseController,
                  decoration: const InputDecoration(
                    labelText: 'Official Response *',
                    hintText: 'Enter formal evaluation or inquiry findings...',
                  ),
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Response is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: actionController,
                  decoration: const InputDecoration(
                    labelText: 'Remedial Action Taken *',
                    hintText: 'e.g., Contractor issued notice, site inspection scheduled...',
                  ),
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Action taken is required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await context.read<ReportProvider>().updateReportStatus(
                      reportId: report.id,
                      status: targetStatus,
                      response: responseController.text.trim(),
                      actionTaken: actionController.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Report successfully marked as ${targetStatus.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Save & Update'),
          ),
        ],
      ),
    );
  }
}

class _StatusCountBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCountBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final CitizenReport report;
  final ValueChanged<ReportStatus> onAction;

  const _ReportCard({required this.report, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.report, color: statusColor, size: 20),
        ),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${AppConstants.reportCategories[report.category] ?? report.category} • ${DateFormat("dd MMM yyyy").format(report.createdAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                const Text('Citizen Complaint Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(report.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      report.isAnonymous ? Icons.visibility_off : Icons.person,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.isAnonymous ? 'Submitted Anonymously' : 'Verified Citizen',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                // Official findings if already resolved or reviewed
                if (report.response != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Official Government Response:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green),
                        ),
                        const SizedBox(height: 2),
                        Text(report.response!, style: const TextStyle(fontSize: 12)),
                        if (report.actionTaken != null) ...[
                          const SizedBox(height: 4),
                          Text('Action: ${report.actionTaken!}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Status Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onAction(ReportStatus.underReview),
                        child: const Text('Review'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onAction(ReportStatus.resolved),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text('Resolve'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => onAction(ReportStatus.rejected),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.underReview:
        return Colors.blue;
      case ReportStatus.rejected:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
