import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void heavyTask(int num) {
  for (int i = 0; i < num; i++) {
    print(i);
  }
}

// Top-level function for compute (cannot be inside a class)
Future<List<dynamic>> fetchComments() async {
  return await compute(
      getCommentsWithCompute, "https://jsonplaceholder.typicode.com/comments");
}

Future<List<dynamic>> getCommentsWithCompute(String url) async {
  final dioClient = Dio();
  final response = await dioClient.get(url);
  return response.data as List<dynamic>;
}

// Isolate.run for Processing: Since Isolate.run expects synchronous code,
// you use it after the data has been fetched asynchronously. Inside the isolate,
// you can handle any synchronous data processing (e.g., parsing, filtering).
Future<List<dynamic>> getCommentsWithIsolateRun() async {
  final dioClient = Dio();
  final response =
      await dioClient.get("https://jsonplaceholder.typicode.com/comments");

  return await Isolate.run(
    () {
      return response.data as List<dynamic>;
    },
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int number = 1000000;
  String url = "https://jsonplaceholder.typicode.com/comments";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator.adaptive(),
            TextButton(
              onPressed: () async {
                final data = await fetchComments();
                print(data);
              },
              child: const Text("Run Heavy Task With Compute"),
            ),
            TextButton(
              onPressed: () async {
                final data = await getCommentsWithIsolateRun();
                print(data);
              },
              child: const Text("Run Heavy Task With Isolate.run"),
            ),
            TextButton(
              onPressed: () {
                heavyTask(1000000);
              },
              child: const Text("Run Heavy Task Without Isolate"),
            )
          ],
        ),
      ),
    );
  }
}
