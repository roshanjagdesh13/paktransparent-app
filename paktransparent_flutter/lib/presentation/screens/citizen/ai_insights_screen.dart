import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/app_constants.dart';

/// AI Budget Insights screen - generates insights dynamically from real project data.
class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
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
        title: const Text('AI Budget Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProjectProvider>().loadProjects(refresh: true),
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = provider.projects;

          if (projects.isEmpty) {
            return const Center(child: Text('No data available to generate insights'));
          }

          // Generate insights from real data
          final insights = _generateInsights(projects);

          return RefreshIndicator(
            onRefresh: () => provider.loadProjects(refresh: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InsightHeader(projectCount: projects.length),
                const SizedBox(height: 16),
                ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _InsightCard(insight: insight),
                )),
                const SizedBox(height: 16),
                _TrendChart(projects: projects),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_Insight> _generateInsights(List<Project> projects) {
    final insights = <_Insight>[];

    final totalBudget = projects.fold(0.0, (s, p) => s + p.budgetAllocated);
    final totalSpent = projects.fold(0.0, (s, p) => s + p.budgetSpent);
    final completedCount = projects.where((p) => p.status == ProjectStatus.completed).length;
    final inProgressCount = projects.where((p) => p.status == ProjectStatus.inProgress).length;
    final pendingCount = projects.where((p) => p.status == ProjectStatus.pending).length;

    // Budget utilization
    final utilization = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0;
    insights.add(_Insight(
      title: 'Budget Utilization',
      text: '${utilization.toStringAsFixed(1)}% of the total allocated budget (Rs ${(totalBudget / 1e9).toStringAsFixed(1)}B) '
          'has been utilized. ${utilization > 80 ? 'Budget is nearing exhaustion — review expenditure.' : utilization < 30 ? 'Low utilization may indicate project delays.' : 'Utilization is on track.'}',
      icon: Icons.trending_up,
      color: utilization > 80 ? Colors.red : utilization < 30 ? Colors.orange : Colors.green,
      severity: utilization > 80 ? _Severity.warning : _Severity.info,
    ));

    // Project delays
    final delayedPct = projects.isNotEmpty ? (pendingCount / projects.length * 100) : 0;
    insights.add(_Insight(
      title: 'Pending Projects',
      text: '$pendingCount projects (${delayedPct.toStringAsFixed(0)}%) are still in pending status. '
          '${delayedPct > 20 ? 'High number of pending projects may indicate approval bottlenecks.' : 'Pending rate is within acceptable limits.'}',
      icon: Icons.pending_actions,
      color: delayedPct > 20 ? Colors.orange : Colors.blue,
      severity: delayedPct > 20 ? _Severity.warning : _Severity.info,
    ));

    // Completion rate
    final completionRate = projects.isNotEmpty ? (completedCount / projects.length * 100) : 0;
    insights.add(_Insight(
      title: 'Completion Rate',
      text: '$completedCount out of ${projects.length} projects are completed (${completionRate.toStringAsFixed(0)}%). '
          '${completionRate > 60 ? 'Excellent completion rate.' : completionRate > 30 ? 'Moderate completion rate — consider accelerating timelines.' : 'Low completion rate — urgent attention needed.'}',
      icon: Icons.check_circle,
      color: completionRate > 60 ? Colors.green : completionRate > 30 ? Colors.orange : Colors.red,
      severity: completionRate > 60 ? _Severity.positive : completionRate > 30 ? _Severity.warning : _Severity.critical,
    ));

    // Top province by budget
    if (projects.isNotEmpty) {
      final provinceBudgets = <Province, double>{};
      for (final p in projects) {
        provinceBudgets[p.province] = (provinceBudgets[p.province] ?? 0) + p.budgetAllocated;
      }
      final topProvince = provinceBudgets.entries.reduce((a, b) => a.value > b.value ? a : b);
      final provinceName = AppConstants.provinces[topProvince.key.name] ?? topProvince.key.name;
      final pct = topProvince.value / totalBudget * 100;
      insights.add(_Insight(
        title: 'Highest Budget Province',
        text: '$provinceName leads with Rs ${(topProvince.value / 1e9).toStringAsFixed(1)}B allocated (${pct.toStringAsFixed(0)}% of total). '
            '${pct > 50 ? 'Consider better distribution across provinces.' : 'Budget distribution appears reasonable.'}',
        icon: Icons.location_on,
        color: Colors.blue,
        severity: pct > 50 ? _Severity.warning : _Severity.info,
      ));
    }

    // Top category by spend
    if (projects.isNotEmpty) {
      final categorySpend = <ProjectCategory, double>{};
      for (final p in projects) {
        categorySpend[p.category] = (categorySpend[p.category] ?? 0) + p.budgetSpent;
      }
      final topCategory = categorySpend.entries.reduce((a, b) => a.value > b.value ? a : b);
      final catName = AppConstants.projectCategories[topCategory.key.name] ?? topCategory.key.name;
      insights.add(_Insight(
        title: 'Highest Spending Category',
        text: '$catName has the highest expenditure at Rs ${(topCategory.value / 1e9).toStringAsFixed(1)}B. '
            'Focus area for financial review and audit.',
        icon: Icons.bar_chart,
        color: Colors.purple,
        severity: _Severity.info,
      ));
    }

    // Cost overrun check
    final overrunProjects = projects.where((p) => p.budgetSpent > p.budgetAllocated).toList();
    if (overrunProjects.isNotEmpty) {
      final totalOverrun = overrunProjects.fold(0.0, (s, p) => s + (p.budgetSpent - p.budgetAllocated));
      insights.add(_Insight(
        title: 'Cost Overruns Detected',
        text: '${overrunProjects.length} project(s) have exceeded their allocated budget by a combined '
            'Rs ${(totalOverrun / 1e6).toStringAsFixed(1)}M. Immediate financial review recommended.',
        icon: Icons.warning_amber,
        color: Colors.red,
        severity: _Severity.critical,
      ));
    }

    // In-progress completion average
    if (inProgressCount > 0) {
      final avgCompletion = projects
          .where((p) => p.status == ProjectStatus.inProgress)
          .fold(0.0, (s, p) => s + p.completionPercentage) / inProgressCount;
      insights.add(_Insight(
        title: 'Active Projects Progress',
        text: '$inProgressCount projects are actively under construction with an average completion of '
            '${avgCompletion.toStringAsFixed(0)}%. ${avgCompletion < 40 ? 'Many projects are in early stages.' : 'Good overall progress.'}',
        icon: Icons.construction,
        color: Colors.teal,
        severity: _Severity.info,
      ));
    }

    return insights;
  }
}

enum _Severity { positive, info, warning, critical }

class _Insight {
  final String title;
  final String text;
  final IconData icon;
  final Color color;
  final _Severity severity;

  _Insight({required this.title, required this.text, required this.icon, required this.color, required this.severity});
}

class _InsightHeader extends StatelessWidget {
  final int projectCount;
  const _InsightHeader({required this.projectCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI-Generated Insights', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Based on $projectCount live projects', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final severityBadge = {
      _Severity.positive: ('Positive', Colors.green),
      _Severity.info: ('Info', Colors.blue),
      _Severity.warning: ('Warning', Colors.orange),
      _Severity.critical: ('Critical', Colors.red),
    }[insight.severity]!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: insight.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(insight.icon, color: insight.color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(insight.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityBadge.$2.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(severityBadge.$1, style: TextStyle(fontSize: 11, color: severityBadge.$2, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(insight.text, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<Project> projects;
  const _TrendChart({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) return const SizedBox.shrink();

    // Show completion percentage distribution as a histogram
    final buckets = List<int>.filled(10, 0);
    for (final p in projects) {
      final bucket = (p.completionPercentage / 10).floor().clamp(0, 9);
      buckets[bucket]++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Project Completion Distribution', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Number of projects by completion %', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (buckets.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                        '${group.x * 10}-${group.x * 10 + 10}%\n${rod.toY.toInt()} projects',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                        reservedSize: 24,
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('${value.toInt() * 10}%', style: const TextStyle(fontSize: 9)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: buckets.asMap().entries.map((e) => BarChartGroupData(
                    x: e.key,
                    barRods: [BarChartRodData(
                      toY: e.value.toDouble(),
                      color: e.key == 9 ? AppConstants.chartSuccess : e.key > 5 ? AppConstants.chartSecondary : AppConstants.chartPrimary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    )],
                  )).toList(),
                  gridData: FlGridData(drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
