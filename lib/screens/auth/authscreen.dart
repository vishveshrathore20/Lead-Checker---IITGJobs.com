import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  String selectedRole = 'LG';
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (isLogin) {
      final res = await AuthService.login(email: email, password: password);

      if (res['success']) {
        final role = (res['role'] ?? '').toLowerCase();

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminDashboard');
        } else if (role == 'lg') {
          Navigator.pushReplacementNamed(context, '/lgDashboard');
        } else {
          _showSnack("Unknown role: $role");
        }
      } else {
        _showSnack(res['message']);
      }
    } else {
      final name = fullNameController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        _showSnack("Passwords do not match");
        return;
      }

      final res = await AuthService.signup(
        name: name,
        email: email,
        password: password,
        role: selectedRole,
      );

      if (res['success']) {
        Navigator.pushNamed(context, '/otp', arguments: {'email': email});
      } else {
        _showSnack(res['message']);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  );

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            isLogin ? 'Welcome' : 'Create your account',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isLogin
                ? 'Please log in to access dashboard'
                : 'Start your journey with IITGJobs.com',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          if (!isLogin) ...[
            Text(
              "Full Name",
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: fullNameController,
              validator: (val) => val!.isEmpty ? 'Full Name is required' : null,
              decoration: _inputDecoration("Your full name"),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            "Email Address",
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: emailController,
            validator: (val) => val!.isEmpty ? 'Email is required' : null,
            decoration: _inputDecoration("Your email address"),
          ),
          const SizedBox(height: 16),

          Text(
            "Password",
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            validator: (val) => val!.isEmpty ? 'Password is required' : null,
            decoration: _inputDecoration("Your password"),
          ),
          const SizedBox(height: 16),

          if (!isLogin) ...[
            Text(
              "Confirm Password",
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              validator: (val) => val!.isEmpty ? 'Confirm your password' : null,
              decoration: _inputDecoration("Re-enter your password"),
            ),
            const SizedBox(height: 16),

            Text(
              "Select Role",
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'LG', child: Text('Lead Generator')),
              ],
              onChanged: (value) => setState(() => selectedRole = value!),
              decoration: _inputDecoration("Choose a role"),
            ),
            const SizedBox(height: 16),
          ],

          if (isLogin) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                    ),
                    Text("Remember Me", style: GoogleFonts.inter(fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: submitForm,
              child: Text(
                isLogin ? "Login" : "Sign Up",
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text("or", style: GoogleFonts.inter()),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text.rich(
                TextSpan(
                  text:
                      isLogin
                          ? "No account registered yet? "
                          : "Already have an account? ",
                  style: GoogleFonts.inter(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: isLogin ? "Register" : "Login",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF007BFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E2A47), Color(0xFF041630)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Welcome to\nIITGJobs.com",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '"Recruitment Redefined. Your Growth, Our Mission."',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "",
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: IntrinsicHeight(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: buildForm(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
