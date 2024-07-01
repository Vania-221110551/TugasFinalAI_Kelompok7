import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../DB/DatabaseHelper.dart';
import '../HomeScreen.dart';
import 'Recognition.dart'; // Ensure this import is correct

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDTH = 112;
  static const int HEIGHT = 112;
  final dbHelper = DatabaseHelper();
  List<Recognition> registered = [];

  @override
  String get modelName => 'assets/mobile_face_net.tflite';

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
    initDB();
  }

  initDB() async {
    await dbHelper.init();
    loadRegisteredFaces();
  }

  void loadRegisteredFaces() async {
    final allRows = await dbHelper.queryAllRows();
    for (final row in allRows) {
      String name = row[DatabaseHelper.columnName];
      List<double> embd = row[DatabaseHelper.columnEmbedding]
          .split(',')
          .map((e) => double.parse(e))
          .toList()
          .cast<double>();

      Recognition recognition = Recognition(name, Rect.zero, embd, 0);
      registered.add(recognition);
    }
  }

  void registerFaceInDB(String name, String embedding) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnEmbedding: embedding
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');

    // Add new recognition to the registered list
    List<double> embd = embedding.split(',').map((e) => double.parse(e)).toList().cast<double>();
    Recognition recognition = Recognition(name, Rect.zero, embd, 0);
    registered.add(recognition);
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage =
        img.copyResize(inputImage!, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble())
        .toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = 112;
    int width = 112;
    Float32List reshapedArray =
        Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          reshapedArray[index] = float32Array[
              c * height * width + h * width + w];
        }
      }
    }
    return reshapedArray.reshape([1, 112, 112, 3]);
  }

  Recognition recognize(img.Image image, Rect location) {
    var input = imageToArray(image);
    print(input.shape.toString());

    List output = List.filled(1 * 192, 0).reshape([1, 192]);

    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms$output');

    List<double> outputArray = output.first.cast<double>();

    Pair pair = findNearest(outputArray);
    print("distance= ${pair.distance}");

    return Recognition(pair.name, location, outputArray, pair.distance);
  }

  findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", -5);
    for (Recognition recognition in registered) {
      print("Hello World");
      final String name = recognition.name;
      List<double> knownEmb = recognition.embeddings;
      double distance = 0;
      print(emb.length);
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - knownEmb[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      print("${pair.name} ${distance} < ${pair.distance}");
      if (distance == 0) {
        print("FOUND");
        pair.distance = distance;
        pair.name = name;
        print("${pair.name} ${distance} < ${pair.distance}");
        break;
      } else if (distance <= 0.25 || distance < pair.distance) {
        print("Change Success");
        pair.distance = distance;
        pair.name = name;
      }
      print("${pair.name} ${distance} < ${pair.distance}");
      if(distance > 0.20){
        pair.name = "Unknown";
      }
    }
    return pair;
  }

  void close() {
    interpreter.close();
  }
}

class Pair {
  String name;
  double distance;
  Pair(this.name, this.distance);
}
