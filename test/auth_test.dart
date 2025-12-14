
import 'package:digital_release_tracker/settings.dart';
import 'package:flutter_test/flutter_test.dart';


// test notification search movies to see if received valid results

// tests to see if login fails as expected 
void main() {
 

    group('AuthService Tests', () {
 
    // PHASE 1: I DO (The Happy Path)
    test('Admin should be able to login with correct credentials', () {
      final auth = AuthService();
      final result = auth.login('admin', 'secure123');
      expect(result, true, reason: 'Admin login should return true');
    });
 
    // PHASE 2: WE DO (Edge Cases)
    test('Admin login fails with wrong password', () {
       final auth = AuthService();
       expect(auth.login('admin', 'wrong'), false);
    });
 
    test('Login should be case sensitive', () {
      final auth = AuthService();
      expect(auth.login('admin', 'Secure123'), false);
 
    });
 
 
  });
}