import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/project_provider.dart';
import '../../../core/routes/app_router.dart';

/// Citizen Home Dashboard.
/// Primary portal for citizens to track public works, scan QR codes on site,
/// submit transparency reports, and view AI-powered analytics.
class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PakTransparent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Project QR Code',
            onPressed: () => Navigator.pushNamed(context, AppRouter.qrScanner),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile & Settings',
            onPressed: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = projectProvider.projects;

          return RefreshIndicator(
            onRefresh: () => projectProvider.loadProjects(refresh: true),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => Text(
                            'Welcome, ${auth.user?.name ?? "Citizen"}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track government projects, public expenditure, and file complaints',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                        const SizedBox(height: 18),

                        // Action cards grid
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.search,
                                title: 'Browse Projects',
                                color: Colors.blue,
                                onTap: () => Navigator.pushNamed(context, AppRouter.projects),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.report_problem,
                                title: 'Report Issue',
                                color: Colors.red,
                                onTap: () => Navigator.pushNamed(context, AppRouter.submitReport),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.list_alt,
                                title: 'My Reports',
                                color: Colors.orange,
                                onTap: () => Navigator.pushNamed(context, AppRouter.myReports),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.analytics,
                                title: 'Analytics',
                                color: Colors.teal,
                                onTap: () => Navigator.pushNamed(context, AppRouter.analytics),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.compare_arrows,
                                title: 'Compare',
                                color: Colors.purple,
                                onTap: () => Navigator.pushNamed(context, AppRouter.budgetComparison),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.auto_awesome,
                                title: 'AI Insights',
                                color: Colors.green,
                                onTap: () => Navigator.pushNamed(context, AppRouter.aiInsights),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tracked Public Projects',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, AppRouter.projects),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (projects.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No projects currently recorded')),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        final isCompleted = project.completionPercentage >= 100;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCompleted
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                              child: Text(
                                '${project.completionPercentage}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.green.shade900 : Colors.blue.shade900,
                                ),
                              ),
                            ),
                            title: Text(
                              project.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${project.district} • Rs ${(project.budgetAllocated / 1e6).toStringAsFixed(1)}M',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouter.projectDetail,
                              arguments: {'projectId': project.id},
                            ),
                          ),
                        );
                      },
                      childCount: projects.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
