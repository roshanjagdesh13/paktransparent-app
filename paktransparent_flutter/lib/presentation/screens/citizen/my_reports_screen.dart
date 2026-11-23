import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/report_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/constants/app_constants.dart';

/// Screen displaying all citizen complaints and reports filed by the active citizen.
/// Shows live tracking of official inquiries, actions taken, and final resolutions.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadMyReports(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submitted Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportProvider>().loadMyReports(refresh: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRouter.submitReport);
          if (mounted) {
            context.read<ReportProvider>().loadMyReports(refresh: true);
          }
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('New Report'),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myReports.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myReports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 72, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No reports submitted yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If you notice delays, substandard materials, or irregularities in a public project, file a report to notify the authorities.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.submitReport),
                      icon: const Icon(Icons.add),
                      label: const Text('File Your First Report'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMyReports(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: provider.myReports.length,
              itemBuilder: (context, index) {
                final report = provider.myReports[index];
                return _MyReportCard(report: report);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MyReportCard extends StatelessWidget {
  final CitizenReport report;

  const _MyReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.report, color: statusColor, size: 20),
        ),
        title: Text(
          report.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                AppConstants.reportCategories[report.category] ?? report.category,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              _StatusBadge(status: report.status),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),
                Text(
                  report.description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      report.isAnonymous ? Icons.visibility_off : Icons.check_circle_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.isAnonymous ? 'Submitted Anonymously' : 'Public Submission',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(report.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),

                // Official resolution panel
                if (report.response != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              'Official Authority Response',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.response!,
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (report.actionTaken != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Action Executed: ${report.actionTaken!}',
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade800),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                if (report.projectId.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.projectDetail,
                        arguments: {'projectId': report.projectId},
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('View Associated Project'),
                  ),
                ],
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

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case ReportStatus.resolved:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        label = 'RESOLVED';
        break;
      case ReportStatus.underReview:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        label = 'UNDER REVIEW';
        break;
      case ReportStatus.rejected:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        label = 'REJECTED';
        break;
      default:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        label = 'SUBMITTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
