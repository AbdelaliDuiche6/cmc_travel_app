import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, String name, String phoneNumber, String role) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user != null) {
     // print('User ID: ${user.id}');
  try {
    await _supabase.from('profiles').insert({
      'id': user.id,
      'name': name,
      'phone_number': phoneNumber,
      'role': role,
    });
  } catch (e) {
    //print('Insert error: $e');
  }
}


    return response;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  // Get user role from profiles table
  Future<String?> fetchUserRole(String userId) async {
    final response = await _supabase
        .from('profiles') // <- updated table name
        .select('role')
        .eq('id', userId) // <- should match 'id' in profiles (same as auth.users.id)
        .single();

    return response['role'];
  }
}
