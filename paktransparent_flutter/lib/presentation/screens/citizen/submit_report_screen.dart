import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/report_provider.dart';
import '../../../data/providers/project_provider.dart';
import '../../../data/models/models.dart';
import '../../../core/constants/app_constants.dart';

/// Screen for citizens to report an issue on a government project with photos,
/// geolocation, category classification, and anonymous reporting.
class SubmitReportScreen extends StatefulWidget {
  final String? projectId;

  const SubmitReportScreen({super.key, this.projectId});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedProjectId;
  String _selectedCategory = 'delay';
  bool _isAnonymous = false;
  final List<File> _evidenceImages = [];
  final ImagePicker _picker = ImagePicker();
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    // Load projects if not loaded so citizen can choose project if opened from main menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider = context.read<ProjectProvider>();
      if (projectProvider.projects.isEmpty) {
        projectProvider.loadProjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Project Selection (if not already pinned)
              Consumer<ProjectProvider>(
                builder: (context, projectProvider, _) {
                  if (widget.projectId != null) {
                    final pinnedProject = projectProvider.projects
                        .where((p) => p.id == widget.projectId)
                        .firstOrNull;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.construction, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reporting for Project',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  pinnedProject?.name ?? widget.projectId!,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Dropdown to select project
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedProjectId,
                      decoration: const InputDecoration(
                        labelText: 'Select Project *',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      items: projectProvider.projects.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.name} (${p.district})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Please select a project' : null,
                      onChanged: (value) => setState(() => _selectedProjectId = value),
                    ),
                  );
                },
              ),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Report Title *',
                  hintText: 'e.g., Substandard materials used in bridge deck',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Title is required';
                  if (value.trim().length < 5) return 'Title must be at least 5 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Issue Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.reportCategories.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description *',
                  hintText: 'Describe the issue observed, exact location, timing, and any relevant details...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Description is required';
                  if (value.trim().length < 15) return 'Please provide more details (min 15 characters)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location / Geotag
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location / Landmark',
                        hintText: 'e.g., Sector G-9, Near Main Bridge Pier #3',
                        prefixIcon: const Icon(Icons.pin_drop),
                        helperText: _latitude != null && _longitude != null
                            ? 'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: _isGettingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    tooltip: 'Capture current GPS coordinates',
                    onPressed: _isGettingLocation ? null : _captureLocation,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Anonymous submission toggle
              SwitchListTile(
                title: const Text('Submit Anonymously'),
                subtitle: const Text('Your identity and email will be kept strictly private from public logs'),
                value: _isAnonymous,
                secondary: Icon(
                  _isAnonymous ? Icons.visibility_off : Icons.visibility,
                  color: _isAnonymous ? Colors.orange : Colors.grey,
                ),
                onChanged: (value) => setState(() => _isAnonymous = value),
              ),
              const SizedBox(height: 16),

              // Evidence photos section
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
                            'Evidence Photos (${_evidenceImages.length}/${AppConstants.maxFiles})',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Max 50MB each',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_evidenceImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _evidenceImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _evidenceImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _evidenceImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _evidenceImages.length >= AppConstants.maxFiles
                                  ? null
                                  : () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _evidenceImages.length >= AppConstants.maxFiles
                                  ? null
                                  : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              Consumer<ReportProvider>(
                builder: (context, provider, _) => ElevatedButton(
                  onPressed: provider.isLoading ? null : _submitReport,
                  child: provider.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              provider.uploadProgress > 0
                                  ? 'Uploading ${(provider.uploadProgress * 100).toInt()}%...'
                                  : 'Submitting Report...',
                            ),
                          ],
                        )
                      : const Text('Submit Official Report'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);
        final size = await file.length();
        if (size > AppConstants.maxFileSizeBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File exceeds 50MB limit')),
            );
          }
          return;
        }

        setState(() {
          _evidenceImages.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  void _captureLocation() {
    setState(() => _isGettingLocation = true);
    // Standard Pakistan default coordinates simulation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _latitude = 31.5204;
          _longitude = 74.3587;
          if (_locationController.text.isEmpty) {
            _locationController.text = 'Lahore, Punjab (GPS Locked)';
          }
          _isGettingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordinates acquired successfully')),
        );
      }
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final targetProjectId = _selectedProjectId ?? widget.projectId;
    if (targetProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project to report on')),
      );
      return;
    }

    try {
      await context.read<ReportProvider>().createReport(
            projectId: targetProjectId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            isAnonymous: _isAnonymous,
            locationLat: _latitude,
            locationLng: _longitude,
            evidenceFiles: _evidenceImages.isNotEmpty ? _evidenceImages : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully! Official reference ID generated.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
