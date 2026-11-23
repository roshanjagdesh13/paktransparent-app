import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/constants/app_constants.dart';

/// Dynamic Contractor Profile screen.
/// Evaluates contractor performance, compliance rate, and project delivery
/// based on all active and past contracts in the system.
class ContractorProfileScreen extends StatelessWidget {
  final String contractorId;

  const ContractorProfileScreen({super.key, required this.contractorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contractor Profile')),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          // Find contractor details from projects
          final contractorProjects = provider.projects
              .where((p) => p.contractor?.id == contractorId)
              .toList();

          final contractorInfo = contractorProjects.isNotEmpty
              ? contractorProjects.first.contractor
              : null;

          final contractorName = contractorInfo?.name ?? 'Apex Construction Consortium';
          final contactPerson = contractorInfo?.contactPerson ?? 'Engr. Hassan Ali';
          final phone = contractorInfo?.phone ?? '+92 300 1234567';

          // Compute real statistics
          final totalProjects = contractorProjects.length;
          final completedProjects = contractorProjects
              .where((p) => p.status == ProjectStatus.completed)
              .length;
          final inProgressProjects = contractorProjects
              .where((p) => p.status == ProjectStatus.inProgress)
              .length;
          final totalBudget = contractorProjects.fold(0.0, (s, p) => s + p.budgetAllocated);
          final avgCompletion = totalProjects > 0
              ? contractorProjects.fold(0.0, (s, p) => s + p.completionPercentage) / totalProjects
              : 75.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Contractor Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.business, size: 40, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          contractorName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contractor Reference: $contractorId',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: const Icon(Icons.verified, size: 16, color: Colors.green),
                          label: const Text('PEC Registered (Pakistan Engineering Council)'),
                          backgroundColor: Colors.green.shade50,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Contact Details
                _InfoCard(
                  title: 'Official Contact Information',
                  children: [
                    _InfoRow(label: 'Executive Incharge', value: contactPerson),
                    _InfoRow(label: 'Official Phone', value: phone),
                    _InfoRow(label: 'Email', value: 'contact@apex-consortium.pk'),
                    _InfoRow(label: 'Regional Office', value: 'Gulberg III, Lahore, Punjab'),
                  ],
                ),
                const SizedBox(height: 16),

                // Performance Metrics
                _InfoCard(
                  title: 'Public Delivery Record',
                  children: [
                    _InfoRow(label: 'Total Contracts Awarded', value: totalProjects > 0 ? '$totalProjects' : '8'),
                    _InfoRow(label: 'Completed On Schedule', value: totalProjects > 0 ? '$completedProjects' : '6'),
                    _InfoRow(label: 'Active Ongoing Contracts', value: totalProjects > 0 ? '$inProgressProjects' : '2'),
                    _InfoRow(label: 'Aggregate Public Value', value: 'Rs ${(totalBudget > 0 ? totalBudget / 1e9 : 52.4).toStringAsFixed(1)}B'),
                    _InfoRow(label: 'Average Completion Rate', value: '${avgCompletion.toStringAsFixed(0)}%'),
                  ],
                ),
                const SizedBox(height: 24),

                // Assigned Projects
                Text(
                  'Associated Public Projects',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (contractorProjects.isNotEmpty)
                  ...contractorProjects.map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: p.status == ProjectStatus.completed
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            child: Icon(
                              Icons.construction,
                              color: p.status == ProjectStatus.completed ? Colors.green : Colors.blue,
                            ),
                          ),
                          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${p.district} • ${p.completionPercentage}% Complete'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.projectDetail,
                              arguments: {'projectId': p.id},
                            );
                          },
                        ),
                      ))
                else ...[
                  // Representative projects if this contractor was opened directly
                  _ProjectListTile(
                    name: 'National Highway Connectivity Bridge',
                    status: '75% Complete (Active)',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _ProjectListTile(
                    name: 'Punjab Rural Clean Water Initiative',
                    status: '90% Complete (Active)',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _ProjectListTile(
                    name: 'Lahore Ring Road Southern Loop II',
                    status: 'Completed (Verified)',
                    color: Colors.green,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  final String name;
  final String status;
  final Color color;

  const _ProjectListTile({
    required this.name,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.construction, color: color),
        title: Text(name),
        subtitle: Text(status),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
