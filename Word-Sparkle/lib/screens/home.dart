import 'package:flutter/material.dart';
import '../customs/customcolors.dart';
import '../customs/custom.elevatedbutton.dart';
import 'addword.dart';
import 'quiz.dart';
import 'settings.dart';
import 'SuccessModulePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _kullaniciId;

  @override
  void initState() {
    super.initState();
    _setKullaniciId();
  }

  Future<void> _setKullaniciId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _kullaniciId = user.uid;
      });
    }
  }

  Widget buildCustomButton({
    // custom.elevatedbuttonunun içerisine aktarılacak
    required String content,
    required VoidCallback onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.only(top: 40),
  }) {
    return Padding(
      padding: padding,
      child: CustomElevatedButton(
        onpressed: onPressed,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomColors.themecolor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  'WORD SPARKLE',
                  style: TextStyle(
                    color: CustomColors.darktextcolor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildCustomButton(
                content: 'Kelime Ekle',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddWord()),
                  );
                },
                padding: const EdgeInsets.only(top: 60),
              ),
              buildCustomButton(
                content: 'Quiz',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Question(questionCount: 10),
                    ),
                  );
                },
              ),
              buildCustomButton(
                content: 'Başarı İstatistiği',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SuccessModulePage(kullaniciId: _kullaniciId),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings,
                          size: 60, color: CustomColors.darktextcolor),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
