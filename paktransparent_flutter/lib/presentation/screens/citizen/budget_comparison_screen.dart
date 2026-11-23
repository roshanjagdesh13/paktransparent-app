import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/app_constants.dart';

/// Budget Comparison screen - compare budgets across provinces and categories.
class BudgetComparisonScreen extends StatefulWidget {
  const BudgetComparisonScreen({super.key});

  @override
  State<BudgetComparisonScreen> createState() => _BudgetComparisonScreenState();
}

class _BudgetComparisonScreenState extends State<BudgetComparisonScreen> {
  Province? _province1;
  Province? _province2;
  bool _hasCompared = false;

  final _provinces = AppConstants.provinces;

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
      appBar: AppBar(title: const Text('Budget Comparison')),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Compare budgets across provinces',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Province>(
                        decoration: const InputDecoration(labelText: 'Province 1'),
                        value: _province1,
                        hint: const Text('Select'),
                        items: Province.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(_provinces[p.name] ?? p.name),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _province1 = value;
                          _hasCompared = false;
                        }),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<Province>(
                        decoration: const InputDecoration(labelText: 'Province 2'),
                        value: _province2,
                        hint: const Text('Select'),
                        items: Province.values
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(_provinces[p.name] ?? p.name),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _province2 = value;
                          _hasCompared = false;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: (_province1 != null && _province2 != null && _province1 != _province2)
                      ? () => setState(() => _hasCompared = true)
                      : null,
                  icon: const Icon(Icons.compare),
                  label: const Text('Compare'),
                ),
                if (_province1 != null && _province2 != null && _province1 == _province2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select two different provinces',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                if (provider.isLoading && provider.projects.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (_hasCompared && _province1 != null && _province2 != null)
                  _ComparisonResult(
                    projects: provider.projects,
                    province1: _province1!,
                    province2: _province2!,
                  )
                else if (!_hasCompared)
                  _EmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.compare_arrows, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'Select two provinces and tap Compare',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ComparisonResult extends StatelessWidget {
  final List<Project> projects;
  final Province province1;
  final Province province2;

  const _ComparisonResult({
    required this.projects,
    required this.province1,
    required this.province2,
  });

  @override
  Widget build(BuildContext context) {
    final p1Projects = projects.where((p) => p.province == province1).toList();
    final p2Projects = projects.where((p) => p.province == province2).toList();

    final p1Budget = p1Projects.fold(0.0, (s, p) => s + p.budgetAllocated);
    final p2Budget = p2Projects.fold(0.0, (s, p) => s + p.budgetAllocated);
    final p1Spent = p1Projects.fold(0.0, (s, p) => s + p.budgetSpent);
    final p2Spent = p2Projects.fold(0.0, (s, p) => s + p.budgetSpent);
    final p1Completed = p1Projects.where((p) => p.status == ProjectStatus.completed).length;
    final p2Completed = p2Projects.where((p) => p.status == ProjectStatus.completed).length;

    final p1Name = AppConstants.provinces[province1.name] ?? province1.name;
    final p2Name = AppConstants.provinces[province2.name] ?? province2.name;

    final maxBudget = p1Budget > p2Budget ? p1Budget : p2Budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(child: _ProvinceCard(
              name: p1Name,
              budget: p1Budget,
              spent: p1Spent,
              projects: p1Projects.length,
              completed: p1Completed,
              color: AppConstants.chartPrimary,
            )),
            const SizedBox(width: 12),
            Expanded(child: _ProvinceCard(
              name: p2Name,
              budget: p2Budget,
              spent: p2Spent,
              projects: p2Projects.length,
              completed: p2Completed,
              color: AppConstants.chartTertiary,
            )),
          ],
        ),
        const SizedBox(height: 24),
        Text('Budget Comparison', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        // Bar chart comparison
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxBudget > 0 ? maxBudget / 1e9 * 1.2 : 1,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0 ? p1Name : p2Name;
                    return BarTooltipItem(
                      '$label\nRs ${rod.toY.toStringAsFixed(1)}B',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)}B', style: const TextStyle(fontSize: 10)),
                    reservedSize: 36,
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
                        child: Text(value.toInt() < labels.length ? labels[value.toInt()] : '', style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                // Allocated
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: p1Budget / 1e9, color: AppConstants.chartPrimary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  BarChartRodData(toY: p2Budget / 1e9, color: AppConstants.chartTertiary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                ]),
                // Spent
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: p1Spent / 1e9, color: AppConstants.chartPrimary.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  BarChartRodData(toY: p2Spent / 1e9, color: AppConstants.chartTertiary.withOpacity(0.7), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                ]),
                // Remaining
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(toY: (p1Budget - p1Spent) / 1e9, color: AppConstants.chartSuccess.withOpacity(0.8), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  BarChartRodData(toY: (p2Budget - p2Spent) / 1e9, color: AppConstants.chartSuccess.withOpacity(0.5), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                ]),
              ],
              gridData: FlGridData(drawVerticalLine: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: AppConstants.chartPrimary, label: p1Name),
            const SizedBox(width: 24),
            _Legend(color: AppConstants.chartTertiary, label: p2Name),
          ],
        ),
        const SizedBox(height: 24),
        // Comparison table
        Text('Detailed Comparison', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _ComparisonTable(
          p1Name: p1Name,
          p2Name: p2Name,
          rows: [
            _CompRow('Total Projects', p1Projects.length.toString(), p2Projects.length.toString()),
            _CompRow('Total Budget', 'Rs ${(p1Budget / 1e9).toStringAsFixed(1)}B', 'Rs ${(p2Budget / 1e9).toStringAsFixed(1)}B'),
            _CompRow('Budget Spent', 'Rs ${(p1Spent / 1e9).toStringAsFixed(1)}B', 'Rs ${(p2Spent / 1e9).toStringAsFixed(1)}B'),
            _CompRow('Completed', p1Completed.toString(), p2Completed.toString()),
            _CompRow('Utilization', p1Budget > 0 ? '${(p1Spent / p1Budget * 100).toStringAsFixed(1)}%' : '0%',
                p2Budget > 0 ? '${(p2Spent / p2Budget * 100).toStringAsFixed(1)}%' : '0%'),
          ],
        ),
      ],
    );
  }
}

class _ProvinceCard extends StatelessWidget {
  final String name;
  final double budget;
  final double spent;
  final int projects;
  final int completed;
  final Color color;

  const _ProvinceCard({
    required this.name,
    required this.budget,
    required this.spent,
    required this.projects,
    required this.completed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final utilization = budget > 0 ? spent / budget * 100 : 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Rs ${(budget / 1e9).toStringAsFixed(1)}B', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('$projects projects', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: utilization / 100, color: color, backgroundColor: color.withOpacity(0.2)),
            const SizedBox(height: 4),
            Text('${utilization.toStringAsFixed(0)}% utilized', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _CompRow {
  final String label;
  final String v1;
  final String v2;
  _CompRow(this.label, this.v1, this.v2);
}

class _ComparisonTable extends StatelessWidget {
  final String p1Name;
  final String p2Name;
  final List<_CompRow> rows;

  const _ComparisonTable({required this.p1Name, required this.p2Name, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
            children: [
              _TableCell('Metric', bold: true),
              _TableCell(p1Name, bold: true),
              _TableCell(p2Name, bold: true),
            ],
          ),
          ...rows.map((r) => TableRow(
            children: [_TableCell(r.label), _TableCell(r.v1), _TableCell(r.v2)],
          )),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  const _TableCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
    );
  }
}
