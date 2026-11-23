import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../core/routes/app_router.dart';

/// Screen for two-factor verification / OTP email confirmation.
/// Includes countdown timer for resending security codes.
class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.mark_email_read,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A 6-digit confirmation code has been sent to\n${widget.email}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, letterSpacing: 14, fontWeight: FontWeight.bold),
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: '6-Digit Code',
                  hintText: '123456',
                  counterText: '',
                  suffixIcon: _otpController.text.length == 6
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                onChanged: (val) {
                  setState(() {});
                  if (val.length == 6) {
                    _verify();
                  }
                },
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => ElevatedButton(
                  onPressed: auth.isLoading ? null : _verify,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & Continue'),
                ),
              ),
              const SizedBox(height: 16),
              if (_canResend)
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend Verification Code'),
                )
              else
                Center(
                  child: Text(
                    'Resend code in $_secondsRemaining seconds',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendOtp() async {
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('A fresh verification code was sent to ${widget.email}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _verify() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the code')),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().verifyOTP(
            email: widget.email,
            otp: code,
          );

      if (mounted) {
        final auth = context.read<AuthProvider>();
        final route = auth.isGovernment
            ? AppRouter.govDashboard
            : AppRouter.citizenHome;
        Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
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
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }
}
