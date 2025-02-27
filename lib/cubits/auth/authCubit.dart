import 'package:eshop_pro/data/models/userDetails.dart';
import 'package:eshop_pro/data/repositories/authRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthProvider { gmail, phone }

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserDetails userDetails;
  final String token;

  Authenticated({required this.userDetails, required this.token});
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial()) {
    checkIsAuthenticated();
  }

  void checkIsAuthenticated() {
    if (AuthRepository.getIsLogIn()) {
      emit(
        Authenticated(
            userDetails: AuthRepository.getUserDetails(),
            token: AuthRepository.getToken()),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  void authenticateUser(
      {required UserDetails userDetails, required String token}) {
    

    authRepository.setToken(token);
    authRepository.setUserDetails(userDetails);
    authRepository.setIsLogIn(true);
    emit(Authenticated(userDetails: userDetails, token: token));
  }

  void unAuthenticateUser() {
    emit(Unauthenticated());
  }

  void signOut(BuildContext context) async {
    String userType = (state as Authenticated).userDetails.type!;
    if (state is Authenticated) {
      await authRepository.signOutUser(context, userType);
      emit(Unauthenticated());
    }
  }

  UserDetails getUserDetails() {
    if (state is Authenticated) {
      return (state as Authenticated).userDetails;
    }

    return UserDetails();
  }
}
