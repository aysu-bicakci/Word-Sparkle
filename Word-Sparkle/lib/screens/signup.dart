import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../customs/customcolors.dart';
import 'login.dart';
import '../customs/input_decorations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late String email, password, userName, passwordControl;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final formkey = GlobalKey<FormState>();

  final firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.themecolor,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleText(),
                      const SizedBox(height: 20),
                      nameTextField(),
                      const SizedBox(height: 20),
                      emailTextField(),
                      const SizedBox(height: 20),
                      passwordTextField(),
                      const SizedBox(height: 20),
                      confirmPasswordTextField(),
                      const SizedBox(height: 20),
                      signUpButton(),
                      const SizedBox(height: 10),
                      loginUpButton(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Text titleText() {
    return const Text(
      'Merhaba, Hoşgeldiniz',
      style: TextStyle(
        fontSize: 30,
        color: CustomColors.darktextcolor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Center signUpButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          if (formkey.currentState!.validate()) {
            formkey.currentState!.save();

            if (password != passwordControl) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifreler eşleşmiyor'),
                  backgroundColor: CustomColors.errorcolor,
                ),
              );
              return;
            }

            try {
              await firebaseAuth.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              formkey.currentState!.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kayıt yapıldı.Giriş yapabilirsiniz.'),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                ),
              );
            }
          }
        },
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
              'Hesap Oluştur',
              style: TextStyle(
                color: CustomColors.themecolor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Center loginUpButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: const Text(
          'Giriş Yap',
          style: TextStyle(color: CustomColors.darktextcolor),
        ),
      ),
    );
  }

  TextFormField nameTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri Eksiksiz Doldurunuz';
        }
        return null;
      },
      onSaved: (value) {
        userName = value!;
      },
      decoration: customInputDecoration('Kullanıcı Adı'),
    );
  }

  TextFormField emailTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri eksiksiz giriniz';
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(value)) {
          return 'Geçerli bir e-posta adresi girin';
        }
        return null;
      },
      onSaved: (value) {
        email = value!;
      },
      decoration: customInputDecoration('Email'),
    );
  }

  TextFormField passwordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri eksiksiz giriniz';
        } else if (value.length < 8) {
          return 'Şifre en az 8 karakter olmalı';
        } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
          return 'Şifre en az bir büyük harf içermeli';
        } else if (!RegExp(r'[a-z]').hasMatch(value)) {
          return 'Şifre en az bir küçük harf içermeli';
        }
        return null;
      },
      onSaved: (value) {
        password = value!;
      },
      obscureText: _obscurePassword,
      decoration: customInputDecoration('Şifre').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  TextFormField confirmPasswordTextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bilgileri eksiksiz giriniz';
        }
        return null;
      },
      onSaved: (value) {
        passwordControl = value!;
      },
      obscureText: _obscureConfirmPassword,
      decoration: customInputDecoration('Şifreyi Tekrar Girin').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
    );
  }
}
