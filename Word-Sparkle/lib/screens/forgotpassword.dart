import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customs/customcolors.dart';
import '../customs/input_decorations.dart';
import 'login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        _showMessageSnackBar(
          context,
          '',
        );
      } on FirebaseAuthException catch (e) {
        _showMessageSnackBar(context, e.message ?? 'Bir hata oluştu.',
            isError: true);
      }
    }
  }

  void _showMessageSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.mail, color: Colors.white),
            SizedBox(width: 8),
            Text('E-posta gönderildi! E-postanızı kontrol edin'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: CustomColors.errorcolor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.themecolor,
      appBar: AppBar(
        backgroundColor: CustomColors.themecolor,
        title: Text('Şifremi Unuttum',
            style: TextStyle(color: CustomColors.buttoncolor)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 130),
                  const Text(
                      'Şifrenizi size e-posta yoluyla gönderebilmemiz için e-posta adresinizi giriniz.',
                      style: TextStyle(
                          fontSize: 19, color: CustomColors.darktextcolor)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: customInputDecoration('Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email boş olamaz.';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'Geçersiz formatta email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return TextButton(
      onPressed: () => passwordReset(context),
      child: Container(
        height: 50,
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: CustomColors.buttoncolor,
        ),
        child: const Center(
          child:
              Text('Gönder', style: TextStyle(color: CustomColors.themecolor)),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: const Text('Giriş Yap',
          style: TextStyle(color: CustomColors.darktextcolor)),
    );
  }
}
