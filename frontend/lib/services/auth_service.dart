import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  // Register new user
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String role = 'EMPLOYEE',
  }) async {
    final response = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });

    final token = response['token'] as String;
    await ApiService.setToken(token);

    return AuthResult(user: User.fromJson(response['user']), token: token);
  }

  // Login
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final token = response['token'] as String;
    await ApiService.setToken(token);

    return AuthResult(user: User.fromJson(response['user']), token: token);
  }

  // Get current user
  static Future<User> getCurrentUser() async {
    final response = await ApiService.get('/auth/me');
    return User.fromJson(response['user']);
  }

  // Logout
  static Future<void> logout() async {
    await ApiService.clearToken();
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null;
  }
}

class AuthResult {
  final User user;
  final String token;

  AuthResult({required this.user, required this.token});
}
