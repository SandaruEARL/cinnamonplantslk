import 'dart:io';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

import '../ml/model_update_service.dart';
import '../ml/ml_preprocessing_service.dart';

class TFLiteService {
  Interpreter? _qualityGradingInterpreter;
  Interpreter? _pricePredictionInterpreter;

  final ModelUpdateService _modelUpdateService;
  final MLPreprocessingService _preprocessingService;

  TFLiteService(this._modelUpdateService, [MLPreprocessingService? preprocessingService])
      : _preprocessingService = preprocessingService ?? MLPreprocessingService();

  bool get _isPriceModelLoaded => _pricePredictionInterpreter != null;

  String? getModelUpdatedAt() {
    return _modelUpdateService.getUpdatedAt();
  }

  Future<void> initialize() async {
    await loadQualityGradingModel();
    await loadPricePredictionModel();
    await _preprocessingService.loadPreprocessing();
    await _preprocessingService.loadRecentData();
  }

  Future<void> loadQualityGradingModel() async {
    try {
      _qualityGradingInterpreter = await Interpreter.fromAsset(
        'assets/models/cinnamon_grader.tflite',
      );
      debugPrint('✅ Quality grading model loaded');
    } catch (e) {
      debugPrint('⚠️  Quality grading model not available: $e');
    }
  }

  Future<void> loadPricePredictionModel() async {
    try {
      final localModel = await _modelUpdateService.getModelFile();

      if (await localModel.exists()) {
        _pricePredictionInterpreter = await Interpreter.fromFile(localModel);
        final version = await _modelUpdateService.getCurrentVersion();
        debugPrint('✅ Price model loaded from storage (v$version)');
        return;
      }

      _pricePredictionInterpreter = await Interpreter.fromAsset(
        'assets/models/price_predictor.tflite',
      );
      debugPrint('✅ Price model loaded from assets');
    } catch (e) {
      debugPrint('⚠️  Price model not available: $e');
    }
  }

  Future<void> reloadPricePredictionModel() async {
    _pricePredictionInterpreter?.close();
    _pricePredictionInterpreter = null;
    await loadPricePredictionModel();
    await _preprocessingService.loadPreprocessing();
    await _preprocessingService.loadRecentData();
  }

  Future<ModelUpdateInfo?> checkForModelUpdate() async {
    return await _modelUpdateService.checkForUpdate();
  }

  Future<bool> installModelUpdate(
      ModelUpdateInfo updateInfo, {
        void Function(double progress)? onProgress,
      }) async {
    final modelSuccess = await _modelUpdateService.downloadAndInstallModel(
      updateInfo,
      onProgress: onProgress,
    );

    if (!modelSuccess) return false;

    final preprocessingSuccess = await _modelUpdateService.downloadPreprocessing();
    final dataSuccess = await _modelUpdateService.downloadRecentData();

    if (!preprocessingSuccess || !dataSuccess) {
      debugPrint('⚠️  Failed to download preprocessing artifacts');
      return false;
    }

    await reloadPricePredictionModel();
    return true;
  }

  Future<String?> getModelVersion() async {
    return await _modelUpdateService.getCurrentVersion();
  }

  Future<Map<String, dynamic>> predictPrices({
    String? district,
    String? grade,
  }) async {
    try {
      if (district == 'National') {
        debugPrint('⚠️  National is a benchmark district, cannot predict');
        return _generateMockPredictions(district, grade);
      }

      if (district == null || district == 'All Districts' ||
          grade == null || grade == 'All Grades') {
        debugPrint('ℹ️  Filters not specific enough, using mock data');
        return _generateMockPredictions(district, grade);
      }

      if (!_isPriceModelLoaded || !_preprocessingService.isLoaded) {
        debugPrint('ℹ️  Model or preprocessing not loaded, using mock data');
        return _generateMockPredictions(district, grade);
      }

      final currentPrice = _preprocessingService.getCurrentPrice(
        district: district,
        grade: grade,
      );

      debugPrint('📊 Current market price (from data): Rs. ${currentPrice.toStringAsFixed(2)}');

      double? nationalPrice;
      try {
        nationalPrice = _preprocessingService.getCurrentPrice(
          district: 'National',
          grade: grade,
        );
        debugPrint('📊 National benchmark price: Rs. ${nationalPrice.toStringAsFixed(2)}');
      } catch (e) {
        debugPrint('⚠️  National benchmark not available: $e');
        nationalPrice = null;
      }

      final isWeekly = _preprocessingService.isWeeklyModel;
      final forecastPeriods = isWeekly ? 4 : 7;

      debugPrint('📅 Model type: ${isWeekly ? 'WEEKLY' : 'DAILY'}');

      final input = _preprocessingService.prepareInput(
        district: district,
        grade: grade,
      );

      final outputSize = forecastPeriods * 2;
      final output = List.filled(outputSize, 0.0).reshape([1, outputSize]);
      _pricePredictionInterpreter!.run(input, output);

      final avgPricesNormalized = output[0].sublist(0, forecastPeriods);
      final highPricesNormalized = output[0].sublist(forecastPeriods, outputSize);

      final avgPrices = _preprocessingService.denormalizePrices(
          avgPricesNormalized, 'average_price_rs_kg');
      final highPrices = _preprocessingService.denormalizePrices(
          highPricesNormalized, 'highest_price_rs_kg');

      List<double>? nationalProjections;
      if (nationalPrice != null) {
        final districtGrowthRate =
            (avgPrices[forecastPeriods - 1] - currentPrice) / currentPrice;
        nationalProjections = List.generate(forecastPeriods, (i) {
          final t = (i + 1) / forecastPeriods.toDouble();
          return nationalPrice! * (1 + (districtGrowthRate * t));
        });
      }

      final now = DateTime.now();
      final predictions = <Map<String, dynamic>>[];

      for (int i = 0; i < forecastPeriods; i++) {
        final daysToAdd = isWeekly ? (i + 1) * 7 : (i + 1);
        predictions.add({
          'date': DateTime(now.year, now.month, now.day + daysToAdd),
          'average_price': avgPrices[i],
          'high_price': highPrices[i],
          'confidence': 85.0 - (i * 5),
          'national_average': nationalProjections?[i],
        });
      }

      final lastPrice = avgPrices[forecastPeriods - 1];
      final trend = lastPrice > currentPrice ? 'upward' : 'downward';
      final periodChange = ((lastPrice - currentPrice) / currentPrice) * 100;

      return {
        'success': true,
        'currentPrice': currentPrice,
        'nationalPrice': nationalPrice,
        'predictions': predictions,
        'monthlyChange': periodChange,
        'weeklyChange': periodChange,
        'trend': trend,
        'district': district,
        'grade': grade,
        'isWeekly': isWeekly,
        'forecastPeriods': forecastPeriods,
        'model_version': await _modelUpdateService.getCurrentVersion(),
        'model_updated_at': _modelUpdateService.getUpdatedAt(), // ✅ added
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Price prediction error: $e');
      debugPrint('Stack trace: $stackTrace');
      return _generateMockPredictions(district, grade);
    }
  }

  Future<Map<String, dynamic>> predictGrade(File imageFile) async {
    try {
      if (_qualityGradingInterpreter == null) {
        return _getMockGradeResult();
      }

      final inputImage = await _preprocessImageForGrading(imageFile);
      final output = List.filled(4, 0.0).reshape([1, 4]);

      _qualityGradingInterpreter!.run(inputImage, output);

      final grades = ['Alba', 'C5', 'C4', 'C3'];
      final probabilities = output[0] as List<double>;

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

  Map<String, dynamic> _generateMockPredictions(String? district, String? grade) {
    final random = Random();
    final basePrice = 1850.0 + (random.nextDouble() * 100 - 50);

    final isWeekly = _preprocessingService.isWeeklyModel;
    final forecastPeriods = isWeekly ? 4 : 7;

    final now = DateTime.now();
    final predictions = <Map<String, dynamic>>[];

    double price = basePrice;
    for (int i = 1; i <= forecastPeriods; i++) {
      price += (random.nextDouble() * 80 - 30);
      final daysToAdd = isWeekly ? i * 7 : i;
      predictions.add({
        'date': DateTime(now.year, now.month, now.day + daysToAdd),
        'average_price': price,
        'high_price': price * 1.05,
        'confidence': 85.0 - (i * 5),
      });
    }

    final periodChange = (random.nextDouble() * 10 - 5);

    return {
      'success': false,
      'mock': true,
      'currentPrice': basePrice,
      'predictions': predictions,
      'monthlyChange': periodChange,
      'weeklyChange': periodChange,
      'trend': random.nextBool() ? 'upward' : 'downward',
      'district': district ?? 'Unknown',
      'grade': grade ?? 'Unknown',
      'isWeekly': isWeekly,
      'forecastPeriods': forecastPeriods,
      // Note: mock predictions intentionally omit model_updated_at
      // so the UI correctly shows nothing for demo data
    };
  }

  Future<List<List<List<List<double>>>>> _preprocessImageForGrading(
      File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) throw Exception('Failed to decode image');

    final resized = img.copyResize(image, width: 224, height: 224);

    return List.generate(
      1,
          (b) => List.generate(
        224,
            (y) => List.generate(
          224,
              (x) {
            final pixel = resized.getPixel(x, y);
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          },
        ),
      ),
    );
  }

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

  void dispose() {
    _qualityGradingInterpreter?.close();
    _pricePredictionInterpreter?.close();
  }
}