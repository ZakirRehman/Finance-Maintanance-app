import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;

  Future<Either<String, User>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<String, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, void>> signOut();

  Future<Either<String, void>> resetPassword(String email);
}
