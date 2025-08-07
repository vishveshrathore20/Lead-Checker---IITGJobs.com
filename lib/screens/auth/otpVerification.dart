import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late String email;
  late String role;

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    email = args?['email'] ?? '';
    role = (args?['role'] ?? '').toLowerCase();

    if (email.isEmpty || role.isEmpty) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid navigation. Missing email/role."),
          ),
        );
        Navigator.pushReplacementNamed(context, '/auth');
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }

    final res = await AuthService.verifyOtp(email: email, otp: otp);

    if (res['success']) {
      // Store token and role
      await _storage.write(key: 'authToken', value: res['token']);
      await _storage.write(key: 'userRole', value: res['role'] ?? '');
      await _storage.write(key: 'userEmail', value: email);

      // Navigate to dashboard based on role
      if ((res['role'] ?? '').toLowerCase() == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/adminDashboard',
          (r) => false,
        );
      } else if ((res['role'] ?? '').toLowerCase() == 'lg') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/lgDashboard',
          (r) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unknown role")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'OTP verification failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 15,
                spreadRadius: 2,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user, size: 48, color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text(
                "OTP Verification",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Enter the code sent to your email ($email).",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _onChanged(val, index),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue.shade600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Verify",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
