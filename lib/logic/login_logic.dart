import 'package:flutter/material.dart';

class LoginLogic {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginLogic() {
    emailController.text = 'demo@informtyping.com';
    passwordController.text = '123456';
  }

  bool onLogin() {
    debugPrint(
      'Login clicked with email: ${emailController.text}, password length: ${passwordController.text.length}',
    );

    return true;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
