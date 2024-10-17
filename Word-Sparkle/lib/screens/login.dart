import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../customs/customcolors.dart';
import '../customs/customtextbutton.dart';
import '../customs/input_decorations.dart';
import 'forgotpassword.dart';
import 'home.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.themecolor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 150),
                  const Text(
                    'Merhaba, Hoşgeldiniz',
                    style: TextStyle(
                      fontSize: 37,
                      color: CustomColors.darktextcolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildTextFormField(
                    hintText: 'Email',
                    onSaved: (value) => email = value,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email boş olamaz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  buildTextFormField(
                    hintText: 'Şifre',
                    onSaved: (value) => password = value,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Şifre boş olamaz.';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                      onPressed: () =>
                          navigateTo(context, const ForgotPassword()),
                      buttonText: 'Şifremi Unuttum',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: loginButton(context),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: CustomTextButton(
                      onPressed: () => navigateTo(context, const SignupPage()),
                      buttonText: 'Hesap Oluştur',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField({
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText,
      decoration: customInputDecoration(hintText),
    );
  }

  Widget loginButton(BuildContext context) {
    return TextButton(
      onPressed: () => login(context),
      child: Container(
        height: 50,
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: CustomColors.buttoncolor,
        ),
        child: const Center(
          child: Text(
            'Giriş Yap',
            style: TextStyle(color: CustomColors.themecolor),
          ),
        ),
      ),
    );
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void showSnackBar(BuildContext context, String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: CustomColors.lighttextcolor),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: CustomColors.errorcolor,
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        showSnackBar(context, 'Giriş bilgileri hatalı.', Icons.close);
      }
    } else {
      showSnackBar(context, 'Lütfen bilgileri eksiksiz doldurun.', Icons.error);
    }
  }
}
