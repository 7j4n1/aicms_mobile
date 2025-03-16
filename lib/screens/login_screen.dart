import 'package:aicms_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final _usernameController = TextEditingController(); // Controller for username field
  final _passwordController = TextEditingController(); // Controller for password field
  bool isLoading = false; // Flag to show loading indicator
  bool obscurePassword = true; // Flag to toggle password visibility


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spacing
                  const SizedBox(height: 60),
                  // App Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Icon(
                        Icons.account_balance_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to AICMS',
                    style: AppTheme.heading1.copyWith(
                      color: AppTheme.primaryColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Spacing
                  const SizedBox(height: 12),
                  Text(
                    'Access your account securely',
                    style: AppTheme.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : _handleLogin,
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text('Login', style: AppTheme.subtitle.copyWith(color: Colors.white),),
                    ),
                  ),
                  // Spacing
                  const SizedBox(height: 20),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      // Navigate to password reset screen
                      // Navigator.pushNamed(context, '/password-reset');
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTheme.bodyText.copyWith(
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to handle login action
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      
      // Perform login action
      try {
        
      } catch (e) {
        // Handle error
        _showErrorSnackBar('Login failed. Please try again.');
      } finally {
        setState(() {
          isLoading = false;
        });
        
      }
    }
  }

  // Method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

}