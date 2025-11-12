import 'package:flutter/material.dart';
import 'stream.dart'; // Pastikan file ini ada
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Evan',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const StreamHomePage(),
    );
  }
}

class StreamHomePage extends StatefulWidget {
  const StreamHomePage({super.key});

  @override
  State<StreamHomePage> createState() => _StreamHomePageState();
}

class _StreamHomePageState extends State<StreamHomePage> {
  // --- Properti Kelas ---
  Color bgColor = Colors.blueGrey;
  late ColorStream colorStream; // Digunakan untuk perubahan warna

  int lastNumber = 0; // Menampilkan angka terakhir dari stream
  late StreamController numberStreamController;
  late NumberStream numberStream;

  // SOLUSI: Inisialisasi StreamTransformer saat deklarasi (late final)
  late final StreamTransformer<int, int> transformer = StreamTransformer<int, int>.fromHandlers(
    handleData: (value, sink) {
      sink.add(value * 10); // Transformasi data: nilai * 10
    },
    handleError: (error, trace, sink) {
      sink.add(-1); // Transformasi error: ganti error dengan nilai -1
    },
    handleDone: (sink) => sink.close()
  );

  // --- Metode Lifecycle ---
  @override
  void initState() {
    super.initState(); // HARUS di baris pertama

    // Inisialisasi untuk ColorStream
    colorStream = ColorStream(); 
    changeColor(); // Mulai perubahan warna

    // Inisialisasi untuk NumberStream
    numberStream = NumberStream();
    numberStreamController = numberStream.controller;
    Stream stream = numberStreamController.stream;

    // Menggunakan transformer
    stream.transform(transformer).listen((event) { 
      setState(() {
        lastNumber = event; // lastNumber menerima nilai yang sudah dikali 10
      });
    }).onError((error) {
      // Callback ini hanya terpicu jika error tidak ditangani oleh transformer
      setState(() {
        lastNumber = -99; 
      });
    });
  }

  @override
  void dispose() {
    numberStreamController.close(); // Tutup controller untuk menghindari memory leak
    super.dispose();
  }

  // --- Metode Bisnis ---

  void changeColor() async {
    // Menggunakan await for atau listen, kode ini menggunakan listen
    colorStream.getColors().listen((eventColor) {
      setState(() {
        bgColor = eventColor;
      });
    });
  }

  void addRandomNumber() {
    Random random = Random();
    int myNum = random.nextInt(10);
    
    // Default: Menambahkan angka acak (akan dikali 10 oleh transformer)
    numberStream.addNumberToSink(myNum); 
    
    // UNTUK UJI ERROR, aktifkan baris di bawah ini dan komentari baris di atas
    // numberStream.addError(); 
  }

  // --- Metode Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream')),
      // Menggunakan bgColor yang diperbarui oleh ColorStream
      body: Container(
        decoration: BoxDecoration(color: bgColor), 
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Menampilkan lastNumber yang diperbarui oleh NumberStream
              Text(
                lastNumber.toString(),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 3.0, color: Colors.black54)
                  ]
                ),
              ),
              ElevatedButton(
                onPressed: () => addRandomNumber(),
                child: const Text('New Random Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}