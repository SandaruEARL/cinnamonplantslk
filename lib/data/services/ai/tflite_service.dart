import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _qualityGradingInterpreter;
  Interpreter?  _pricePredictionInterpreter;

  // Load quality grading model
  Future<void> loadQualityGradingModel() async {
    try {
      _qualityGradingInterpreter = await Interpreter.fromAsset(
        'assets/models/cinnamon_grader.tflite',
      );
      print('Quality grading model loaded successfully');
    } catch (e) {
      print('Failed to load quality grading model: $e');
      // Model not found - will use mock data for now
    }
  }

  // Load price prediction model
  Future<void> loadPricePredictionModel() async {
    try {
      _pricePredictionInterpreter = await Interpreter.fromAsset(
        'assets/models/price_predictor.tflite',
      );
      print('Price prediction model loaded successfully');
    } catch (e) {
      print('Failed to load price prediction model: $e');
      // Model not found - will use mock data for now
    }
  }

  // Predict cinnamon grade from image
  Future<Map<String, dynamic>> predictGrade(File imageFile) async {
    try {
      if (_qualityGradingInterpreter == null) {
        // Return mock data if model not loaded
        return _getMockGradeResult();
      }

      // Preprocess image
      final inputImage = await _preprocessImageForGrading(imageFile);

      // Prepare output buffer
      final output = List. filled(4, 0.0). reshape([1, 4]);

      // Run inference
      _qualityGradingInterpreter! .run(inputImage, output);

      // Process results
      final grades = ['Alba', 'C5', 'C4', 'C3'];
      final probabilities = output[0] as List<double>;

      // Find max probability
      double maxProb = probabilities[0];
      int maxIndex = 0;
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      return {
        'grade': grades[maxIndex],
        'confidence': maxProb * 100,
        'probabilities': {
          for (int i = 0; i < grades.length; i++)
            grades[i]: probabilities[i] * 100,
        },
      };
    } catch (e) {
      throw Exception('Failed to predict grade: $e');
    }
  }

  // Predict future prices
  Future<Map<String, dynamic>> predictPrices() async {
    try {
      if (_pricePredictionInterpreter == null) {
        // Return mock data if model not loaded
        return _getMockPriceResult();
      }

      // For now, return mock data
      // In production, you'd prepare historical price data and run inference
      return _getMockPriceResult();
    } catch (e) {
      throw Exception('Failed to predict prices: $e');
    }
  }

  // Preprocess image for quality grading
  Future<List<List<List<List<double>>>>> _preprocessImageForGrading(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) throw Exception('Failed to decode image');

    // Resize to 224x224 (typical input size for image classification models)
    final resized = img.copyResize(image, width: 224, height: 224);

    // Normalize pixel values to [0, 1]
    final input = List. generate(
      1,
          (b) => List.generate(
        224,
            (y) => List.generate(
          224,
              (x) {
            final pixel = resized.getPixel(x, y);
            return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }

  // Mock data for quality grading (when model not available)
  Map<String, dynamic> _getMockGradeResult() {
    return {
      'grade': 'Alba',
      'confidence': 92.5,
      'probabilities': {
        'Alba': 92.5,
        'C5': 5.3,
        'C4': 1.8,
        'C3': 0.4,
      },
    };
  }

  // Mock data for price prediction (when model not available)
  Map<String, dynamic> _getMockPriceResult() {
    final now = DateTime.now();
    return {
      'currentPrice': 825.0,
      'predictions': [
        {
          'month': DateTime(now.year, now.month + 1),
          'price': 875.0,
          'confidence': 85.0,
        },
        {
          'month': DateTime(now.year, now.month + 2),
          'price': 920.0,
          'confidence': 78.0,
        },
        {
          'month': DateTime(now.year, now.month + 3),
          'price': 890.0,
          'confidence': 72.0,
        },
      ],
      'trend': 'upward',
      'weeklyChange': 5.2,
    };
  }

  // Dispose interpreters
  void dispose() {
    _qualityGradingInterpreter?.close();
    _pricePredictionInterpreter?.close();
  }
}