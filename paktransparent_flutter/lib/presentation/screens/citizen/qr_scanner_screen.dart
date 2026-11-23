import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/project_provider.dart';
import '../../../core/routes/app_router.dart';

/// QR Scanner screen - scans project QR codes to quickly navigate to project details.
/// Uses the mobile_scanner package for real camera-based QR scanning.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;
  bool _torchEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Project QR Code'),
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() => _torchEnabled = !_torchEnabled);
              _scannerController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _scannerController.switchCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
                // Overlay with scanning frame
                CustomPaint(
                  size: Size.infinite,
                  painter: _ScanOverlayPainter(),
                ),
                // Scanning line animation
                const _ScanLine(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Point your camera at a project QR code',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _enterManually,
                    child: const Text('Enter Project ID manually'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasScanned = true);
    _scannerController.stop();

    // Parse project ID from QR code
    // Expected format: "paktransparent://project/{projectId}" or just the projectId
    String projectId;
    if (rawValue.startsWith('paktransparent://project/')) {
      projectId = rawValue.replaceFirst('paktransparent://project/', '');
    } else {
      projectId = rawValue.trim();
    }

    if (projectId.isEmpty) {
      _showError('Invalid QR code format');
      return;
    }

    _navigateToProject(projectId);
  }

  void _navigateToProject(String projectId) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.projectDetail,
      arguments: {'projectId': projectId},
    );
  }

  void _enterManually() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Project ID'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Project ID',
              hintText: 'Enter the project ID',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final id = controller.text.trim();
                if (id.isNotEmpty) {
                  Navigator.pop(context);
                  _navigateToProject(id);
                }
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    setState(() => _hasScanned = false);
    _scannerController.start();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

/// Custom painter for the scanning overlay frame.
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final frameSize = size.width * 0.7;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;
    final frameRect = Rect.fromLTWH(left, top, frameSize, frameSize);

    // Draw dark overlay excluding the scan frame
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Draw frame border
    final borderPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Corner accents
    const cornerLength = 24.0;
    final corners = [
      // Top-left
      [Offset(left, top + cornerLength), Offset(left, top), Offset(left + cornerLength, top)],
      // Top-right
      [Offset(left + frameSize - cornerLength, top), Offset(left + frameSize, top), Offset(left + frameSize, top + cornerLength)],
      // Bottom-left
      [Offset(left, top + frameSize - cornerLength), Offset(left, top + frameSize), Offset(left + cornerLength, top + frameSize)],
      // Bottom-right
      [Offset(left + frameSize - cornerLength, top + frameSize), Offset(left + frameSize, top + frameSize), Offset(left + frameSize, top + frameSize - cornerLength)],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated scanning line.
class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final frameSize = constraints.maxWidth * 0.7;
            final left = (constraints.maxWidth - frameSize) / 2;
            final top = (constraints.maxHeight - frameSize) / 2;
            final lineY = top + (_animation.value * frameSize);

            return Positioned(
              left: left,
              top: lineY,
              child: Container(
                width: frameSize,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0),
                      Colors.green,
                      Colors.green.withOpacity(0),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
