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
  String message = '';
 
  void _handleLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;
 
    // Use our Service to check credentials
    final success = _authService.login(username, password);
 
    if (success) {
      setState(() => message = 'Success');
    } else {
      // Show Error
      setState(() => message = 'Invalid Credentials');
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
            if (message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  message,
                  style: TextStyle(color: message != "Success" ? Colors.red : Colors.green,
                ),
              ))
          ],
        ),
      ),
    );
  }
}