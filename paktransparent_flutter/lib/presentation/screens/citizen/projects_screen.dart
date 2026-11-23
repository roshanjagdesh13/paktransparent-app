import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/constants/app_constants.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  Province? _selectedProvince;
  ProjectCategory? _selectedCategory;
  ProjectStatus? _selectedStatus;
  bool _filtersApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<ProjectProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Projects'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (_filtersApplied)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProjectProvider>().clearFilters();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                setState(() {});
                // Debounce: only search when user stops typing
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == query && mounted) {
                    context.read<ProjectProvider>().searchProjects(query);
                  }
                });
              },
              onSubmitted: (query) {
                context.read<ProjectProvider>().searchProjects(query);
              },
            ),
          ),
          // Active filter chips
          if (_filtersApplied)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_selectedProvince != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(AppConstants.provinces[_selectedProvince!.name] ?? _selectedProvince!.name),
                        onDeleted: () {
                          setState(() => _selectedProvince = null);
                          _applyFilters();
                        },
                      ),
                    ),
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(AppConstants.projectCategories[_selectedCategory!.name] ?? _selectedCategory!.name),
                        onDeleted: () {
                          setState(() => _selectedCategory = null);
                          _applyFilters();
                        },
                      ),
                    ),
                  if (_selectedStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedStatus!.name),
                        onDeleted: () {
                          setState(() => _selectedStatus = null);
                          _applyFilters();
                        },
                      ),
                    ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.projects.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.error ?? 'Failed to load projects'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadProjects(refresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('No projects found'),
                        const SizedBox(height: 8),
                        const Text('Try adjusting your filters', style: TextStyle(color: Colors.grey)),
                        if (_filtersApplied) ...[
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _clearAllFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadProjects(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: provider.projects.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.projects.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final project = provider.projects[index];
                      return _ProjectCard(project: project);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    // Capture current values to allow cancel
    Province? tmpProvince = _selectedProvince;
    ProjectCategory? tmpCategory = _selectedCategory;
    ProjectStatus? tmpStatus = _selectedStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filter Projects', style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          tmpProvince = null;
                          tmpCategory = null;
                          tmpStatus = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Province', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Province.values.map((p) {
                        final name = AppConstants.provinces[p.name] ?? p.name;
                        return FilterChip(
                          label: Text(name),
                          selected: tmpProvince == p,
                          onSelected: (selected) => setModalState(() => tmpProvince = selected ? p : null),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Category', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ProjectCategory.values.map((cat) {
                        final name = AppConstants.projectCategories[cat.name] ?? cat.name;
                        return FilterChip(
                          label: Text(name),
                          selected: tmpCategory == cat,
                          onSelected: (selected) => setModalState(() => tmpCategory = selected ? cat : null),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Status', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ProjectStatus.values.map((status) => FilterChip(
                        label: Text(status.name),
                        selected: tmpStatus == status,
                        onSelected: (selected) => setModalState(() => tmpStatus = selected ? status : null),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedProvince = tmpProvince;
                      _selectedCategory = tmpCategory;
                      _selectedStatus = tmpStatus;
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    final filters = ProjectFilters(
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      province: _selectedProvince,
      category: _selectedCategory,
      status: _selectedStatus,
    );
    _filtersApplied = _selectedProvince != null || _selectedCategory != null || _selectedStatus != null;
    context.read<ProjectProvider>().applyFilters(filters);
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _selectedProvince = null;
      _selectedCategory = null;
      _selectedStatus = null;
      _filtersApplied = false;
    });
    context.read<ProjectProvider>().clearFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.projectDetail,
          arguments: {'projectId': project.id},
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: project.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 2),
                  Text(
                    '${project.district}, ${AppConstants.provinces[project.province.name] ?? project.province.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 2),
                  Text(
                    AppConstants.projectCategories[project.category.name] ?? project.category.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: project.completionPercentage / 100,
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${project.completionPercentage}% complete', style: Theme.of(context).textTheme.bodySmall),
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 14, color: Colors.grey.shade600),
                      Text(
                        'Rs ${(project.budgetAllocated / 1e6).toStringAsFixed(1)}M',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ProjectStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = {
      ProjectStatus.completed: (Colors.green.shade100, Colors.green.shade800),
      ProjectStatus.inProgress: (Colors.blue.shade100, Colors.blue.shade800),
      ProjectStatus.pending: (Colors.orange.shade100, Colors.orange.shade800),
      ProjectStatus.suspended: (Colors.grey.shade200, Colors.grey.shade800),
      ProjectStatus.cancelled: (Colors.red.shade100, Colors.red.shade800),
      ProjectStatus.approved: (Colors.teal.shade100, Colors.teal.shade800),
      ProjectStatus.requiresApproval: (Colors.amber.shade100, Colors.amber.shade800),
    }[status];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config?.$1 ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name,
        style: TextStyle(fontSize: 11, color: config?.$2 ?? Colors.grey.shade800, fontWeight: FontWeight.w600),
      ),
    );
  }
}
