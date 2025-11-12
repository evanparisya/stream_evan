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
  // --- Properti ---
  Color bgColor = Colors.blueGrey;
  late ColorStream colorStream;
  int lastNumber = 0; // Digunakan untuk .onError
  late StreamController numberStreamController;
  late NumberStream numberStream;
  
  // Variabel dari langkah sebelumnya
  late StreamSubscription subscription; 
  late StreamSubscription subscription2;
  String values = ''; 

  // --- Metode Lifecycle ---
  @override
  void initState() {
    super.initState(); 

    // ColorStream
    colorStream = ColorStream(); 
    changeColor(); 

    // NumberStream
    numberStream = NumberStream();
    numberStreamController = numberStream.controller;
    
    // LANGKAH 4: Set broadcast stream
    // Mengubah stream menjadi broadcast agar bisa didengarkan >1x
    Stream stream = numberStreamController.stream.asBroadcastStream();

    // Listener 1 (sekarang aman digunakan)
    subscription = stream.listen((event) {
      setState(() {
        values += '$event - '; // Menambahkan data ke string
      });
    });

    // Listener 2 (sekarang aman digunakan)
    subscription2 = stream.listen((event) {
      setState(() {
        values += '$event - '; // Menambahkan data ke string
      });
    });
    
    // Menerapkan logic .onError/onDone dari langkah sebelumnya
    subscription.onError((error) {
      setState(() {
        lastNumber = -1; // Menampilkan -1 jika ada error
      });
    });
    subscription.onDone(() {
      print('onDone 1 was called');
    });
  }

  @override
  void dispose() {
    numberStreamController.close();
    subscription.cancel(); // Membatalkan subscription 1
    subscription2.cancel(); // Membatalkan subscription 2
    super.dispose();
  }
  
  // --- Metode Bisnis ---
  
  void changeColor() async {
    colorStream.getColors().listen((eventColor) {
      setState(() {
        bgColor = eventColor;
      });
    });
  }

  void stopStream() {
    numberStreamController.close();
  }

  void addRandomNumber() {
    Random random = Random();
    int myNum = random.nextInt(10);
    
    if (!numberStreamController.isClosed) {
      numberStream.addNumberToSink(myNum); 
    } else {
      setState(() {
        lastNumber = -1; 
      });
    }
  }

  // LANGKAH 5: Edit method build()
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream')),
      body: Container(
        decoration: BoxDecoration(color: bgColor), 
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Menampilkan string 'values' yang diperbarui oleh kedua listener
              Text(
                values.isEmpty ? 'Tekan Tombol' : values, 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              // Menampilkan 'lastNumber' hanya jika ada error
              if (lastNumber == -1)
                const Text(
                  'ERROR/STREAM CLOSED', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ElevatedButton(
                onPressed: () => addRandomNumber(),
                child: const Text('New Random Number'),
              ),
              ElevatedButton(
                onPressed: () => stopStream(),
                child: const Text('Stop Subscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}