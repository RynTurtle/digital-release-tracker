import 'package:flutter/material.dart';

class AuthService {
  bool login(String username, String password) {
    // Hardcoded User 1: Admin
    if (username == 'admin' && password == 'secure123') {
      return true;
    }
 
    // Hardcoded User 2: Standard User
    if (username == 'user' && password == 'guest') {
      return true;
    }
 
    // Default: Login fails
    return false;
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String _errorMessage = '';
 
  void _handleLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;
 
    // Use our Service to check credentials
    final success = _authService.login(username, password);
 
    if (success) {
      setState(() => _errorMessage = '');
    } else {
      // Show Error
      setState(() => _errorMessage = 'Invalid Credentials');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Login'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Success',
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}