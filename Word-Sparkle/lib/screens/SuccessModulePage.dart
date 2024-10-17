// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:last_projectt/customs/customCardWidget.dart';
import 'package:last_projectt/customs/customcolors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rxdart/rxdart.dart';

import 'constants.dart';

class SuccessModulePage extends StatelessWidget {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  final String kullaniciId;

  SuccessModulePage({required this.kullaniciId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.themecolor,
        title: Text(
          'Başarı Modülü',
          style: TextStyle(
            color: CustomColors.buttoncolor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              var result = await _captureAndConvertToPdf(context);
              if (result != null) {
                await Printing.layoutPdf(onLayout: (_) => result);
              } else {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('PDF Oluşturma Hatası'),
                    content: Text('PDF oluşturulurken bir hata oluştu.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Tamam'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: CombineLatestStream.list([
          FirebaseFirestore.instance
              .collection('users')
              .doc(kullaniciId)
              .collection('words')
              .snapshots(),
          FirebaseFirestore.instance
              .collection('users')
              .doc(kullaniciId)
              .collection('known_words')
              .snapshots(),
        ]),
        builder: (BuildContext context,
            AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Veri alınamadı: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var wordsSnapshot = snapshot.data![0];
          var knownWordsSnapshot = snapshot.data![1];

          // Grafiğe veri hazırlama
          var wordsData = wordsSnapshot.docs;
          var knownWordsData = knownWordsSnapshot.docs;

          var consecutiveCorrectCounts = <int, int>{
            1: 0,
            2: 0,
            3: 0,
            4: 0,
            5: 0
          };
          var knownWordsCount = knownWordsData.length;

          wordsData.forEach((doc) {
            var wordData = doc.data() as Map<String, dynamic>;
            int consecutiveCorrect = wordData['artArdaDogru'] ?? 0;
            if (consecutiveCorrectCounts.containsKey(consecutiveCorrect)) {
              consecutiveCorrectCounts[consecutiveCorrect] =
                  consecutiveCorrectCounts[consecutiveCorrect]! + 1;
            }
          });

          var series = <charts.Series<ConsecutiveCorrectData, String>>[
            charts.Series(
              id: 'ConsecutiveCorrect',
              data: consecutiveCorrectCounts.entries
                  .map(
                      (entry) => ConsecutiveCorrectData(entry.key, entry.value))
                  .toList(),
              domainFn: (ConsecutiveCorrectData data, _) =>
                  '${data.count}' + '.seviye',
              measureFn: (ConsecutiveCorrectData data, _) => data.frequency,
              colorFn: (_, __) => charts.MaterialPalette.gray.shade800,
            ),
            charts.Series(
              id: 'KnownWords',
              data: [ConsecutiveCorrectData(0, knownWordsCount)],
              domainFn: (ConsecutiveCorrectData data, _) => 'Bilinen Kelimeler',
              measureFn: (ConsecutiveCorrectData data, _) => data.frequency,
              colorFn: (_, __) => charts.MaterialPalette.black,
            ),
          ];

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: CustomColors.darktextcolor,
                  height: 0.5,
                ),
                RepaintBoundary(
                  key: _printKey,
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        padding: EdgeInsets.all(16),
                        child: charts.BarChart(
                          series,
                          animate: true,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: wordsSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          var wordData = wordsSnapshot.docs[index].data()
                              as Map<String, dynamic>;

                          int correctCount = wordData[totalCorrectField] ?? 0;
                          int incorrectCount = wordData[totalWrongField] ?? 0;
                          int consecutiveCorrect =
                              wordData['artArdaDogru'] ?? 0;

                          var totalAttempts = correctCount + incorrectCount;
                          var successRate = totalAttempts != 0
                              ? (correctCount / totalAttempts) * 100
                              : 0.0;

                          return Card(
                            color: CustomColors.buttoncolor,
                            child: ListTile(
                              title: CustomCardWidget(
                                text: 'Kelime: ${wordData['ingilizce']}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomCardWidget(
                                    text: 'Doğru Sayısı: $correctCount',
                                  ),
                                  CustomCardWidget(
                                    text: 'Yanlış Sayısı: $incorrectCount',
                                  ),
                                  CustomCardWidget(
                                    text:
                                        'Başarı Oranı: ${successRate.toStringAsFixed(2)}%',
                                  ),
                                  CustomCardWidget(
                                    text: 'Art Arda Doğru: $consecutiveCorrect',
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: CustomColors.themecolor,
    );
  }

  Future<Uint8List?> _captureAndConvertToPdf(BuildContext context) async {
    try {
      var boundary =
          _printKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      pdf.addPage(pw.Page(
          build: (pw.Context context) => pw.Image(pw.MemoryImage(pngBytes))));

      Uint8List? result = await pdf.save();
      return result;
    } catch (e) {
      print('PDF oluşturma hatası: $e');
      return null;
    }
  }
}

class ConsecutiveCorrectData {
  final int count;
  final int frequency;

  ConsecutiveCorrectData(this.count, this.frequency);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Bir hata oluştu: ${snapshot.error}');
        }
        if (snapshot.hasData && snapshot.data != null) {
          var user = snapshot.data!;
          var kullaniciId = user.uid;
          return MaterialApp(
            home: SuccessModulePage(kullaniciId: kullaniciId),
          );
        }
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Giriş yapın.'),
            ),
          ),
        );
      },
    );
  }
}
