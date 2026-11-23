import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/app_constants.dart';

/// Budget Analytics screen - shows real charts using fl_chart from project data.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'By Province'),
            Tab(text: 'By Category'),
          ],
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.projects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = provider.projects;

          return TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(projects: projects),
              _ProvinceTab(projects: projects, touchedIndex: _touchedIndex, onTouch: (i) => setState(() => _touchedIndex = i)),
              _CategoryTab(projects: projects),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ─── Overview Tab ───────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final List<Project> projects;

  const _OverviewTab({required this.projects});

  @override
  Widget build(BuildContext context) {
    final totalBudget = projects.fold(0.0, (sum, p) => sum + p.budgetAllocated);
    final totalSpent = projects.fold(0.0, (sum, p) => sum + p.budgetSpent);
    final completedCount = projects.where((p) => p.status == ProjectStatus.completed).length;
    final inProgressCount = projects.where((p) => p.status == ProjectStatus.inProgress).length;

    return RefreshIndicator(
      onRefresh: () => context.read<ProjectProvider>().loadProjects(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(
                  title: 'Total Budget',
                  value: 'Rs ${(totalBudget / 1e9).toStringAsFixed(1)}B',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  title: 'Total Projects',
                  value: projects.length.toString(),
                  icon: Icons.construction,
                  color: Colors.green,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(
                  title: 'Completed',
                  value: completedCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.purple,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  title: 'In Progress',
                  value: inProgressCount.toString(),
                  icon: Icons.pending,
                  color: Colors.orange,
                )),
              ],
            ),
            const SizedBox(height: 24),
            // Budget utilization bar chart
            Text('Budget Utilization', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (projects.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: _BudgetUtilizationChart(totalBudget: totalBudget, totalSpent: totalSpent),
              ),
              const SizedBox(height: 8),
              _LegendRow(
                items: [
                  _LegendItem('Spent', Colors.blue, 'Rs ${(totalSpent / 1e9).toStringAsFixed(1)}B'),
                  _LegendItem('Remaining', Colors.green, 'Rs ${((totalBudget - totalSpent) / 1e9).toStringAsFixed(1)}B'),
                ],
              ),
            ] else
              const Center(child: Text('No data available')),
            const SizedBox(height: 24),
            // Status distribution
            Text('Project Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (projects.isNotEmpty)
              SizedBox(
                height: 200,
                child: _StatusPieChart(projects: projects),
              )
            else
              const Center(child: Text('No data available')),
          ],
        ),
      ),
    );
  }
}

class _BudgetUtilizationChart extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const _BudgetUtilizationChart({required this.totalBudget, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final remaining = totalBudget - totalSpent;
    final spentPct = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: totalBudget / 1e9,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                'Rs ${rod.toY.toStringAsFixed(1)}B',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)}B',
                style: const TextStyle(fontSize: 10),
              ),
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = ['Allocated', 'Spent', 'Remaining'];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    value.toInt() < labels.length ? labels[value.toInt()] : '',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalBudget / 1e9, color: AppConstants.chartPrimary)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalSpent / 1e9, color: AppConstants.chartTertiary)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: remaining / 1e9, color: AppConstants.chartSuccess)]),
        ],
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: totalBudget / 1e9 / 4,
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  final List<Project> projects;

  const _StatusPieChart({required this.projects});

  @override
  Widget build(BuildContext context) {
    final statusCounts = <ProjectStatus, int>{};
    for (final p in projects) {
      statusCounts[p.status] = (statusCounts[p.status] ?? 0) + 1;
    }

    final colors = {
      ProjectStatus.completed: AppConstants.chartSuccess,
      ProjectStatus.inProgress: AppConstants.chartTertiary,
      ProjectStatus.pending: AppConstants.chartWarning,
      ProjectStatus.suspended: AppConstants.chartGray,
      ProjectStatus.cancelled: AppConstants.chartError,
      ProjectStatus.approved: AppConstants.chartSecondary,
      ProjectStatus.requiresApproval: AppConstants.chartWarning,
    };

    return PieChart(
      PieChartData(
        sections: statusCounts.entries.map((e) {
          final pct = e.value / projects.length * 100;
          return PieChartSectionData(
            value: e.value.toDouble(),
            title: '${pct.toStringAsFixed(0)}%',
            color: colors[e.key] ?? AppConstants.chartGray,
            radius: 70,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

// ─── Province Tab ────────────────────────────────────────────────────────────

class _ProvinceTab extends StatelessWidget {
  final List<Project> projects;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _ProvinceTab({required this.projects, required this.touchedIndex, required this.onTouch});

  @override
  Widget build(BuildContext context) {
    // Group by province
    final provinceBudgets = <Province, double>{};
    for (final p in projects) {
      provinceBudgets[p.province] = (provinceBudgets[p.province] ?? 0) + p.budgetAllocated;
    }

    if (provinceBudgets.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sorted = provinceBudgets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppConstants.chartPrimary, AppConstants.chartSecondary, AppConstants.chartTertiary,
      AppConstants.chartSuccess, AppConstants.chartWarning, AppConstants.chartError,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Budget by Province', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions && response?.touchedSection != null) {
                      onTouch(response!.touchedSection!.touchedSectionIndex);
                    } else {
                      onTouch(-1);
                    }
                  },
                ),
                sections: sorted.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final isTouched = i == touchedIndex;
                  final pct = e.value / provinceBudgets.values.fold(0.0, (s, v) => s + v) * 100;
                  return PieChartSectionData(
                    value: e.value,
                    title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
                    color: colors[i % colors.length],
                    radius: isTouched ? 90 : 75,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          ...sorted.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final provinceName = AppConstants.provinces[e.key.name] ?? e.key.name;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 16, height: 16, decoration: BoxDecoration(
                    color: colors[i % colors.length],
                    borderRadius: BorderRadius.circular(4),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: Text(provinceName)),
                  Text('Rs ${(e.value / 1e9).toStringAsFixed(1)}B',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Category Tab ────────────────────────────────────────────────────────────

class _CategoryTab extends StatelessWidget {
  final List<Project> projects;

  const _CategoryTab({required this.projects});

  @override
  Widget build(BuildContext context) {
    final categoryBudgets = <ProjectCategory, double>{};
    for (final p in projects) {
      categoryBudgets[p.category] = (categoryBudgets[p.category] ?? 0) + p.budgetAllocated;
    }

    if (categoryBudgets.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sorted = categoryBudgets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = sorted.first.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Budget by Category', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue / 1e9,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final categoryName = AppConstants.projectCategories[sorted[groupIndex].key.name] ?? sorted[groupIndex].key.name;
                      return BarTooltipItem(
                        '$categoryName\nRs ${rod.toY.toStringAsFixed(1)}B',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)}B', style: const TextStyle(fontSize: 9)),
                      reservedSize: 36,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i >= sorted.length) return const SizedBox.shrink();
                        final name = AppConstants.projectCategories[sorted[i].key.name] ?? sorted[i].key.name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              name.length > 8 ? name.substring(0, 8) : name,
                              style: const TextStyle(fontSize: 9),
                            ),
                          ),
                        );
                      },
                      reservedSize: 60,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sorted.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [BarChartRodData(
                      toY: entry.value.value / 1e9,
                      color: AppConstants.chartPrimary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    )],
                  );
                }).toList(),
                gridData: FlGridData(drawVerticalLine: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;
  final String value;
  _LegendItem(this.label, this.color, this.value);
}

class _LegendRow extends StatelessWidget {
  final List<_LegendItem> items;
  const _LegendRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('${item.label}: ${item.value}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      )).toList(),
    );
  }
}
