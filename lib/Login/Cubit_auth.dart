// // cubit_auth.dart
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// // Define the AuthState classes
// abstract class AuthState {}
//
// class AuthInitial extends AuthState {}
// class AuthLoading extends AuthState {}
// class AuthAuthenticated extends AuthState {} // Define this state for authenticated users
// class AuthError extends AuthState {
//   final String message;
//   AuthError(this.message);
// }
//
// class AuthCubit extends Cubit<AuthState> {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   AuthCubit() : super(AuthInitial());
//
//   // Check current user and if email is verified
//   Future<void> checkCurrentUser() async {
//     final user = _firebaseAuth.currentUser;
//     if (user != null && user.emailVerified) {
//       emit(AuthAuthenticated()); // Emit AuthAuthenticated state
//     } else {
//       emit(AuthError("User is not authenticated or email not verified"));
//     }
//   }
//
//   // Handle sign in
//   Future<void> signIn(String email, String password) async {
//     try {
//       emit(AuthLoading());
//       await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
//       emit(AuthAuthenticated()); // After sign in, emit AuthAuthenticated
//     } catch (e) {
//       emit(AuthError("Login failed: ${e.toString()}"));
//     }
//   }
//
//   // Handle sign up
//   Future<void> signUp(String email, String password) async {
//     try {
//       emit(AuthLoading());
//       await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
//       emit(AuthAuthenticated()); // After sign up, emit AuthAuthenticated
//     } catch (e) {
//       emit(AuthError("Signup failed: ${e.toString()}"));
//     }
//   }
//
//   // Handle sign out
//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//     emit(AuthInitial());
//   }
// }
