import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/models.dart';
import '../../../data/models/government.dart';
import '../../../core/constants/app_constants.dart';

/// Screen for government officials to sanction and publish a public project.
/// Includes fiscal approval authority checking against official hierarchy.
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _contractorPhoneController = TextEditingController();
  final _latController = TextEditingController(text: '31.5204');
  final _lngController = TextEditingController(text: '74.3587');

  Province _selectedProvince = Province.punjab;
  ProjectCategory _selectedCategory = ProjectCategory.infrastructure;
  DateTime? _startDate;
  DateTime? _expectedEndDate;
  double _parsedBudget = 0.0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userGovRole = auth.user?.governmentRole ?? GovernmentRole.section_officer;
    final approvalCheck = canUserApproveProject(userGovRole, _parsedBudget);
    final approvalLevel = getRequiredApprovalLevel(_parsedBudget);

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Project')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Project Identification
              _SectionHeading(title: 'Project Identification'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Official Project Title *',
                  hintText: 'e.g., Rawalpindi Ring Road Phase 1',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Project title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Scope of Work & Objectives *',
                  hintText: 'Detailed description of project deliverables, beneficiaries, and technical scope...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.trim().length < 15
                    ? 'Provide a comprehensive description (min 15 chars)'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProjectCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Sector Category *', prefixIcon: Icon(Icons.category)),
                items: AppConstants.projectCategories.entries
                    .map((e) => DropdownMenuItem(
                          value: ProjectCategory.values.firstWhere((cat) => cat.name == e.key),
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 24),

              // Fiscal Allocation & Authority
              _SectionHeading(title: 'Fiscal Allocation & Authority'),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sanctioned Budget (PKR) *',
                  hintText: 'Enter amount in PKR (e.g., 2500000000)',
                  prefixText: 'Rs ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (val) {
                  final clean = val.replaceAll(',', '').trim();
                  setState(() {
                    _parsedBudget = double.tryParse(clean) ?? 0.0;
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Budget is required';
                  final amount = double.tryParse(value.replaceAll(',', ''));
                  if (amount == null || amount <= 0) return 'Enter a valid positive budget amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Multi-level approval hierarchy banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: approvalCheck.canApprove ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: approvalCheck.canApprove ? Colors.green.shade300 : Colors.amber.shade400,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          approvalCheck.canApprove ? Icons.verified_user : Icons.gavel,
                          color: approvalCheck.canApprove ? Colors.green.shade800 : Colors.amber.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Required Authority Level: Level $approvalLevel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: approvalCheck.canApprove ? Colors.green.shade900 : Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      approvalCheck.canApprove
                          ? 'Your executive authority (${roleInfo[userGovRole]?.title ?? "Official"}) is authorized to sanction this budget.'
                          : 'Sanction Notice: Budget exceeds individual ceiling. Escalation will route to ${approvalCheck.escalateTo != null ? roleInfo[approvalCheck.escalateTo]?.title : "competent authority"}.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location & Region
              _SectionHeading(title: 'Geographic Location'),
              DropdownButtonFormField<Province>(
                value: _selectedProvince,
                decoration: const InputDecoration(labelText: 'Province *', prefixIcon: Icon(Icons.map)),
                items: AppConstants.provinces.entries
                    .map((e) => DropdownMenuItem(
                          value: Province.values.firstWhere((p) => p.name == e.key),
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedProvince = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District *',
                  hintText: 'e.g., Rawalpindi, Peshawar, Quetta',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'District is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Site Address / Landmarks',
                  hintText: 'e.g., Near Motorway Interchange M-2',
                  prefixIcon: Icon(Icons.pin_drop),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Latitude', prefixIcon: Icon(Icons.explore)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Longitude', prefixIcon: Icon(Icons.explore)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Execution Timeline
              _SectionHeading(title: 'Timeline & Milestones'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _startDate == null ? 'Start Date' : DateFormat('dd MMM yyyy').format(_startDate!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isStart: false),
                      icon: const Icon(Icons.event),
                      label: Text(
                        _expectedEndDate == null
                            ? 'Target Completion'
                            : DateFormat('dd MMM yyyy').format(_expectedEndDate!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contractor Assignment
              _SectionHeading(title: 'Contractor Assignment (Optional)'),
              TextFormField(
                controller: _contractorNameController,
                decoration: const InputDecoration(
                  labelText: 'Awarded Contractor Name',
                  hintText: 'e.g., Frontier Works Organisation (FWO)',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contractorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contractor Contact Phone',
                  hintText: '+92 300 0000000',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<ProjectProvider>(
                builder: (context, provider, _) => ElevatedButton(
                  onPressed: provider.isLoading ? null : _createProject,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sanction & Publish Project'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_expectedEndDate ?? now.add(const Duration(days: 365))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _expectedEndDate = picked;
        }
      });
    }
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    final budget = double.tryParse(_budgetController.text.replaceAll(',', ''));
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid budget amount')),
      );
      return;
    }

    final lat = double.tryParse(_latController.text) ?? 31.5204;
    final lng = double.tryParse(_lngController.text) ?? 74.3587;

    try {
      final projectData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory.name,
        'budgetAllocated': budget,
        'budgetReleased': budget * 0.25, // Standard initial release
        'budgetSpent': 0.0,
        'province': _selectedProvince.name,
        'district': _districtController.text.trim(),
        'completionPercentage': 0,
        'status': ProjectStatus.approved.name,
        if (_startDate != null) 'startDate': _startDate!.toIso8601String(),
        if (_expectedEndDate != null) 'expectedEndDate': _expectedEndDate!.toIso8601String(),
        'location': {
          'lat': lat,
          'lng': lng,
          'address': _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : '${_districtController.text.trim()}, ${_selectedProvince.name}',
        },
      };

      if (_contractorNameController.text.trim().isNotEmpty) {
        projectData['contractor'] = {
          'id': 'c_${DateTime.now().millisecondsSinceEpoch}',
          'name': _contractorNameController.text.trim(),
          'phone': _contractorPhoneController.text.trim(),
          'contactPerson': 'Executive Project Manager',
        };
      }

      await context.read<ProjectProvider>().createProject(projectData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project sanctioned and published successfully to national registry!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Creation failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _contractorNameController.dispose();
    _contractorPhoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
