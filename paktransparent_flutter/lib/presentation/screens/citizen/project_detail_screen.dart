import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/constants/app_constants.dart';

/// Full-featured project details screen with budget breakdowns, milestone timeline,
/// contractor profile link, share/bookmark actions, and QR code view.
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjectDetails(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedProject == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final project = provider.selectedProject;
          if (project == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Project Details')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Project not found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final isBookmarked = project.isBookmarked;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 4),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (project.heroImage != null)
                        Image.network(
                          project.heroImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildHeaderBanner(context),
                        )
                      else
                        _buildHeaderBanner(context),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // QR code modal
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    tooltip: 'Project QR Code',
                    onPressed: () => _showQrDialog(context, project),
                  ),
                  // Bookmark
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                    tooltip: isBookmarked ? 'Remove Bookmark' : 'Bookmark Project',
                    onPressed: () {
                      provider.toggleBookmark(project.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBookmarked
                                ? 'Removed from bookmarks'
                                : 'Project bookmarked successfully',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // Share
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share Project',
                    onPressed: () => _shareProject(context, project),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and category badges
                      Row(
                        children: [
                          _buildStatusBadge(project.status),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              AppConstants.projectCategories[project.category.name] ??
                                  project.category.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          const Spacer(),
                          // Follow button
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _isFollowing = !_isFollowing);
                              provider.toggleFollow(project.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isFollowing
                                        ? 'Now following ${project.name}'
                                        : 'Unfollowed project',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              _isFollowing ? Icons.notifications_active : Icons.notifications_none,
                              size: 16,
                            ),
                            label: Text(_isFollowing ? 'Following' : 'Follow'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: const Size(60, 36),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _SectionTitle(title: 'Overview'),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Budget section
                      _SectionTitle(title: 'Financial Breakdown'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _BudgetTile(
                              label: 'Allocated',
                              amount: project.budgetAllocated,
                              color: AppConstants.chartPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _BudgetTile(
                              label: 'Spent',
                              amount: project.budgetSpent,
                              color: AppConstants.chartTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _BudgetTile(
                              label: 'Remaining',
                              amount: project.budgetRemaining,
                              color: AppConstants.chartSuccess,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Budget utilization visual bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: project.budgetAllocated > 0
                              ? (project.budgetSpent / project.budgetAllocated).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 12,
                          color: AppConstants.chartTertiary,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget Utilized: ${(project.budgetAllocated > 0 ? (project.budgetSpent / project.budgetAllocated * 100) : 0).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'PKR Standard Rate',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Physical Progress section
                      _SectionTitle(title: 'Physical Progress'),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${project.completionPercentage}% Completed',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    project.status == ProjectStatus.completed
                                        ? '100% Target Met'
                                        : 'In Execution',
                                    style: TextStyle(
                                      color: project.status == ProjectStatus.completed
                                          ? Colors.green
                                          : Colors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: project.completionPercentage / 100,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(6),
                                color: AppConstants.chartPrimary,
                              ),
                              if (project.startDate != null || project.expectedEndDate != null) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (project.startDate != null)
                                      Expanded(
                                        child: _DateColumn(
                                          label: 'Commenced',
                                          date: project.startDate!,
                                        ),
                                      ),
                                    if (project.expectedEndDate != null)
                                      Expanded(
                                        child: _DateColumn(
                                          label: 'Expected Completion',
                                          date: project.expectedEndDate!,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Milestones Timeline
                      if (project.milestones.isNotEmpty) ...[
                        _SectionTitle(title: 'Project Milestones'),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: project.milestones.asMap().entries.map((entry) {
                                final index = entry.key;
                                final milestone = entry.value;
                                final isLast = index == project.milestones.length - 1;
                                return _MilestoneRow(
                                  milestone: milestone,
                                  isLast: isLast,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Contractor Details
                      if (project.contractor != null) ...[
                        _SectionTitle(title: 'Assigned Contractor'),
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: const Icon(Icons.business),
                            ),
                            title: Text(
                              project.contractor!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Contact: ${project.contractor!.contactPerson ?? "Executive Incharge"}\nPhone: ${project.contractor!.phone ?? "Not provided"}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.contractorProfile,
                                arguments: {'contractorId': project.contractor!.id},
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Location & Department Details
                      _SectionTitle(title: 'Location & Department'),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _InfoItem(
                                icon: Icons.location_on,
                                label: 'Province & District',
                                value:
                                    '${AppConstants.provinces[project.province.name] ?? project.province.name}, ${project.district}',
                              ),
                              if (project.location?.address != null) ...[
                                const Divider(),
                                _InfoItem(
                                  icon: Icons.map,
                                  label: 'Site Address',
                                  value: project.location!.address!,
                                ),
                              ],
                              if (project.department != null) ...[
                                const Divider(),
                                _InfoItem(
                                  icon: Icons.account_balance,
                                  label: 'Governing Department',
                                  value: project.department!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Report Issue CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRouter.submitReport,
                            arguments: {'projectId': project.id},
                          ),
                          icon: const Icon(Icons.report_problem),
                          label: const Text('Report an Issue / Complaint'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: const Center(
        child: Icon(Icons.account_balance, size: 80, color: Colors.white70),
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case ProjectStatus.completed:
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case ProjectStatus.inProgress:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case ProjectStatus.pending:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        break;
      case ProjectStatus.suspended:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade900;
        break;
      case ProjectStatus.cancelled:
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
      default:
        bg = Colors.teal.shade100;
        fg = Colors.teal.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _shareProject(BuildContext context, Project project) {
    final shareContent = '''
🏛️ *${project.name}*
📍 Location: ${project.district}, ${project.province.name}
💰 Allocated Budget: Rs ${(project.budgetAllocated / 1e6).toStringAsFixed(1)}M
📊 Completion: ${project.completionPercentage}% (${project.status.name})
Track real-time updates and public expenditure on PakTransparent:
https://paktransparent.gov.pk/projects/${project.id}
''';

    Clipboard.setData(ClipboardData(text: shareContent));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Project Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project summary copied to clipboard!'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shareContent,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 160, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'paktransparent://project/${project.id}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Citizens can scan this QR code on site to view project progress, budget release, and submit reports.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _BudgetTile({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Rs ${(amount / 1e6).toStringAsFixed(1)}M',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateColumn({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          DateFormat('dd MMM yyyy').format(date),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final Milestone milestone;
  final bool isLast;

  const _MilestoneRow({required this.milestone, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = milestone.status == 'completed';
    final isInProgress = milestone.status == 'in_progress';

    Color dotColor = isDone ? Colors.green : (isInProgress ? Colors.blue : Colors.grey);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: Colors.green)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Target: ${DateFormat("MMM yyyy").format(milestone.targetDate)} • ${milestone.status.replaceAll("_", " ").toUpperCase()}',
                    style: TextStyle(fontSize: 11, color: dotColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
