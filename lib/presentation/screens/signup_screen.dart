import 'package:flutter/material.dart';
import '../../data/models/signup_model.dart';
import '../../data/repositories/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 2. State Variables
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  // 3. Logic
  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      // 1. Check Terms
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to Terms of Service')),
        );
        return;
      }

      setState(() => _isLoading = true);

      // 2. Prepare Request
      final request = SignUpRequest(
        name: _nameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        address: _addressController.text,
      );

      // 3. Call API
      bool success = await _authRepository.signUp(request);

      setState(() => _isLoading = false);

      // 4. Handle Result
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created Successfully! Please Login.'),
            backgroundColor: Color(0xFF34D186), // Success Green
          ),
        );

        // FIX: Use pushReplacementNamed to go to Login cleanly
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign Up Failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Green color from your design
    final primaryColor = const Color(0xFF34D186);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Sign Up", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Header
              Center(
                child: Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shopping_bag, size: 40, color: primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Create Account", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Join us to get fresh groceries delivered\nto your doorstep in minutes.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // --- FIELDS ---

              // 1. Name (New Field for JSON 'name')
              _buildLabel("Full Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Enter your name", Icons.person_outline),
                validator: (val) => val!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),

              // 2. Phone Number (With Validation)
              _buildLabel("Phone Number"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Enter phone number", Icons.phone_outlined),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Phone is required";
                  if (val.length < 10) return "Phone must be at least 10 digits";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. Address (Maps to JSON 'address')
              _buildLabel("Delivery Address"),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration("Enter address (e.g. IIT Jammu)", Icons.location_on_outlined),
                validator: (val) => val!.isEmpty ? "Address is required" : null,
              ),
              const SizedBox(height: 16),

              // 4. Password
              _buildLabel("Password"),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Create a password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => val!.length < 4 ? "Password too short" : null,
              ),
              const SizedBox(height: 16),

              // 5. Confirm Password (UI only)
              _buildLabel("Confirm Password"),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration("Confirm your password", Icons.lock_outline),
                validator: (val) {
                  if (val != _passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Terms Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: primaryColor,
                    onChanged: (val) => setState(() => _agreedToTerms = val!),
                  ),
                  const Expanded(child: Text("I agree to the Terms of Service & Privacy Policy")),
                ],
              ),
              const SizedBox(height: 24),

              // Sign Up Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Input Styling
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}