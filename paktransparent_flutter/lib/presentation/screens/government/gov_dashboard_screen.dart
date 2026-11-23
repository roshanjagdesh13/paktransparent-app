import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/project_provider.dart';
import '../../../data/providers/report_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/routes/app_router.dart';

/// Government administrative dashboard.
/// Provides live metrics on national public works, pending citizen complaints,
/// budget execution rates, and rapid administrative actions.
class GovDashboardScreen extends StatefulWidget {
  const GovDashboardScreen({super.key});

  @override
  State<GovDashboardScreen> createState() => _GovDashboardScreenState();
}

class _GovDashboardScreenState extends State<GovDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(refresh: true);
      context.read<ReportProvider>().loadReports(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Real-Time Data',
            onPressed: () async {
              await context.read<ProjectProvider>().loadProjects(refresh: true);
              await context.read<ReportProvider>().loadReports(refresh: true);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dashboard synchronized with national database'), duration: Duration(seconds: 1)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile & Settings',
            onPressed: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
        ],
      ),
      body: Consumer2<ProjectProvider, ReportProvider>(
        builder: (context, projectProvider, reportProvider, _) {
          final projects = projectProvider.projects;
          final totalBudget = projects.fold(0.0, (s, p) => s + p.budgetAllocated);
          final totalSpent = projects.fold(0.0, (s, p) => s + p.budgetSpent);
          final inProgressCount = projects.where((p) => p.status == ProjectStatus.inProgress).length;

          return RefreshIndicator(
            onRefresh: () async {
              await projectProvider.loadProjects(refresh: true);
              await reportProvider.loadReports(refresh: true);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Official Card
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => Card(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.shield, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.user?.name ?? 'Government Official',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  auth.user?.designation ?? 'Administrative Authority',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Employee ID: ${auth.user?.employeeCode ?? "PAK-GOV-001"}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Live Stat Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Active Projects',
                        value: projects.isNotEmpty ? '${projects.length}' : '0',
                        subtext: '$inProgressCount underway',
                        icon: Icons.construction,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Citizen Reports',
                        value: '${reportProvider.pendingReports}',
                        subtext: '${reportProvider.reports.length} total filed',
                        icon: Icons.report_problem,
                        color: reportProvider.pendingReports > 0 ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Sanctioned Budget',
                        value: 'Rs ${(totalBudget / 1e9).toStringAsFixed(1)}B',
                        subtext: 'Fiscal Year 2024-25',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Expenditure',
                        value: 'Rs ${(totalSpent / 1e9).toStringAsFixed(1)}B',
                        subtext: '${totalBudget > 0 ? (totalSpent / totalBudget * 100).toStringAsFixed(0) : 0}% disbursed',
                        icon: Icons.trending_up,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text('Administrative Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.add_circle,
                  title: 'Sanction New Project',
                  subtitle: 'Publish public project with budget & milestones',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, AppRouter.createProject),
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.gavel,
                  title: 'Review Citizen Complaints',
                  subtitle: '${reportProvider.pendingReports} pending inquiries requiring official action',
                  color: Colors.orange,
                  badgeCount: reportProvider.pendingReports,
                  onTap: () => Navigator.pushNamed(context, AppRouter.citizenReports),
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.verified_user,
                  title: 'Official Audit Trail',
                  subtitle: 'Immutable record of approvals, modifications, and disbursements',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, AppRouter.auditTrail),
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.analytics,
                  title: 'National Budget Analytics',
                  subtitle: 'Province & category distribution charts',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, AppRouter.analytics),
                ),

                const SizedBox(height: 24),

                // Managed Projects list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registered Projects', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.projects),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (projectProvider.isLoading && projects.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (projects.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No projects currently registered. Create your first project above.')),
                    ),
                  )
                else
                  ...projects.take(5).map((project) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: project.status == ProjectStatus.completed
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                          child: Text(
                            '${project.completionPercentage}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: project.status == ProjectStatus.completed ? Colors.green : Colors.blue,
                            ),
                          ),
                        ),
                        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${project.district} • Rs ${(project.budgetAllocated / 1e6).toStringAsFixed(1)}M'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.projectDetail,
                          arguments: {'projectId': project.id},
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(subtext, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int? badgeCount;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
