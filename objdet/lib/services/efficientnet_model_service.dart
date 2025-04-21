import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class EfficientNetService {
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/efficientnet-lite0-fp32.tflite');
    _labels = await _loadLabels();
    print("Model and labels loaded");
  }

  Future<List<String>> _loadLabels() async {
    final rawLabels = await rootBundle.loadString('assets/labels.txt');
    return rawLabels.split('\n');
  }

  Future<List<Map<String, dynamic>>> runModel(File imageFile) async {
    final raw = imageFile.readAsBytesSync();
    img.Image? image = img.decodeImage(raw);
    if (image == null) throw Exception(" Cannot decode image");

    img.Image resized = img.copyResize(image, width: 224, height: 224);

    List<List<List<List<double>>>> input = List.generate(1, (_) =>
      List.generate(224, (y) =>
        List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        })
      )
    );

    var output = List.filled(1000, 0.0).reshape([1, 1000]);

    _interpreter.run(input, output);

    final results = List<double>.from(output[0]);

final indexedScores = results.asMap().entries.toList()
  ..sort((MapEntry<int, double> a, MapEntry<int, double> b) => b.value.compareTo(a.value));

return indexedScores.take(5).map((entry) {
final fullLabel = _labels[entry.key]; // Get the full label
  final namePart = fullLabel.split('.').last;
    final score = entry.value;
  return {
    'label': namePart,
    'score': score,
  };
}).toList();
  }
}
