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

  /// Check if models are loaded
  bool get _isPriceModelLoaded => _pricePredictionInterpreter != null;

  /// Initialize models
  Future<void> initialize() async {
    await loadQualityGradingModel();
    await loadPricePredictionModel();

    // Load preprocessing artifacts
    await _preprocessingService.loadPreprocessing();
    await _preprocessingService.loadRecentData();
  }

  /// Load quality grading model (from assets)
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

  /// Load price prediction model (from local storage or assets)
  Future<void> loadPricePredictionModel() async {
    try {
      // Try local storage first (updated model)
      final localModel = await _modelUpdateService.getModelFile();

      if (await localModel.exists()) {
        _pricePredictionInterpreter = await Interpreter.fromFile(localModel);
        final version = await _modelUpdateService.getCurrentVersion();
        debugPrint('✅ Price model loaded from storage (v$version)');
        return;
      }

      // Fallback to bundled model
      _pricePredictionInterpreter = await Interpreter.fromAsset(
        'assets/models/price_predictor.tflite',
      );
      debugPrint('✅ Price model loaded from assets');

    } catch (e) {
      debugPrint('⚠️  Price model not available: $e');
    }
  }

  /// Reload price model after update
  Future<void> reloadPricePredictionModel() async {
    _pricePredictionInterpreter?.close();
    _pricePredictionInterpreter = null;
    await loadPricePredictionModel();

    // Reload preprocessing data
    await _preprocessingService.loadPreprocessing();
    await _preprocessingService.loadRecentData();
  }

  /// Check for model updates
  Future<ModelUpdateInfo?> checkForModelUpdate() async {
    return await _modelUpdateService.checkForUpdate();
  }

  /// Install model update
  Future<bool> installModelUpdate(
      ModelUpdateInfo updateInfo, {
        void Function(double progress)? onProgress,
      }) async {
    // Download model
    final modelSuccess = await _modelUpdateService.downloadAndInstallModel(
      updateInfo,
      onProgress: onProgress,
    );

    if (!modelSuccess) return false;

    // Download preprocessing.json and recent_data.csv
    final preprocessingSuccess = await _modelUpdateService.downloadPreprocessing();
    final dataSuccess = await _modelUpdateService.downloadRecentData();

    if (!preprocessingSuccess || !dataSuccess) {
      debugPrint('⚠️  Failed to download preprocessing artifacts');
      return false;
    }

    // Reload everything
    await reloadPricePredictionModel();

    return true;
  }

  /// Get current model version
  Future<String?> getModelVersion() async {
    return await _modelUpdateService.getCurrentVersion();
  }

  /// Predict prices with district and grade (WEEKLY MODEL - 4 WEEKS)
  Future<Map<String, dynamic>> predictPrices({
    String? district,
    String? grade,
  }) async {
    try {
      // ✅ Block National predictions - it's a reference, not a target
      if (district == 'National') {
        debugPrint('⚠️  National is a benchmark district, cannot predict');
        return _generateMockPredictions(district, grade);
      }

      // Handle null or "All" filters
      if (district == null || district == 'All Districts' ||
          grade == null || grade == 'All Grades') {
        debugPrint('ℹ️  Filters not specific enough, using mock data');
        return _generateMockPredictions(district, grade);
      }

      if (!_isPriceModelLoaded || !_preprocessingService.isLoaded) {
        debugPrint('ℹ️  Model or preprocessing not loaded, using mock data');
        return _generateMockPredictions(district, grade);
      }

      // Get actual current price from recent data BEFORE preparing input
      final currentPrice = _preprocessingService.getCurrentPrice(
        district: district,
        grade: grade,
      );

      debugPrint('📊 Current market price (from data): Rs. ${currentPrice.toStringAsFixed(2)}');

      // ✅ Fetch National benchmark separately (not predicted)
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

      // ✅ Check if model is weekly or daily
      final isWeekly = _preprocessingService.isWeeklyModel;
      final lookbackPeriods = isWeekly ? 12 : 30; // 12 weeks or 30 days
      final forecastPeriods = isWeekly ? 4 : 7;   // 4 weeks or 7 days

      debugPrint('📅 Model type: ${isWeekly ? 'WEEKLY' : 'DAILY'}');
      debugPrint('   Lookback: $lookbackPeriods ${isWeekly ? 'weeks' : 'days'}');
      debugPrint('   Forecast: $forecastPeriods ${isWeekly ? 'weeks' : 'days'}');

      // Prepare input
      final input = _preprocessingService.prepareInput(
        district: district,
        grade: grade,
      );

      // Run inference
      final outputSize = forecastPeriods * 2; // avg + high prices
      final output = List.filled(outputSize, 0.0).reshape([1, outputSize]);
      _pricePredictionInterpreter!.run(input, output);

      // Parse output: first half = avg prices, second half = high prices (NORMALIZED)
      final avgPricesNormalized = output[0].sublist(0, forecastPeriods);
      final highPricesNormalized = output[0].sublist(forecastPeriods, outputSize);

      debugPrint('📊 Model output (normalized):');
      debugPrint('   Avg: $avgPricesNormalized');
      debugPrint('   High: $highPricesNormalized');

      // ✅ DENORMALIZE back to actual prices
      final avgPrices = _preprocessingService.denormalizePrices(
          avgPricesNormalized,
          'average_price_rs_kg'
      );
      final highPrices = _preprocessingService.denormalizePrices(
          highPricesNormalized,
          'highest_price_rs_kg'
      );

      debugPrint('💰 Denormalized predictions:');
      debugPrint('   Avg: $avgPrices');
      debugPrint('   High: $highPrices');

      // ✅ Calculate projected national benchmark (simple trend projection)
      List<double>? nationalProjections;
      if (nationalPrice != null) {
        final districtGrowthRate = (avgPrices[forecastPeriods - 1] - currentPrice) / currentPrice;
        nationalProjections = List.generate(forecastPeriods, (i) {
          final t = (i + 1) / forecastPeriods.toDouble();
          return nationalPrice! * (1 + (districtGrowthRate * t));
        });
        debugPrint('📊 National projections: $nationalProjections');
      }

      // Create predictions
      final now = DateTime.now();
      final predictions = <Map<String, dynamic>>[];

      for (int i = 0; i < forecastPeriods; i++) {
        // ✅ For weekly model: add 7 days per week, for daily: add 1 day per prediction
        final daysToAdd = isWeekly ? (i + 1) * 7 : (i + 1);

        predictions.add({
          'date': DateTime(now.year, now.month, now.day + daysToAdd),
          'average_price': avgPrices[i],
          'high_price': highPrices[i],
          'confidence': 85.0 - (i * 5), // Decreases over time
          'national_average': nationalProjections?[i],
        });
      }

      // Calculate trend (compare last prediction with current actual price)
      final lastPrice = avgPrices[forecastPeriods - 1];
      final trend = lastPrice > currentPrice ? 'upward' : 'downward';

      // Calculate change over forecast period
      final periodChange = ((lastPrice - currentPrice) / currentPrice) * 100;

      return {
        'success': true,
        'currentPrice': currentPrice,
        'nationalPrice': nationalPrice,
        'predictions': predictions,
        'monthlyChange': periodChange, // ✅ For weekly model, this is 4-week change
        'weeklyChange': periodChange,  // Keep for backward compatibility
        'trend': trend,
        'district': district,
        'grade': grade,
        'isWeekly': isWeekly, // ✅ NEW: Flag to indicate model type
        'forecastPeriods': forecastPeriods,
        'model_version': await _modelUpdateService.getCurrentVersion(),
      };

    } catch (e, stackTrace) {
      debugPrint('❌ Price prediction error: $e');
      debugPrint('Stack trace: $stackTrace');
      return _generateMockPredictions(district, grade);
    }
  }

  /// Predict cinnamon grade from image
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

  /// Generate mock predictions (for testing or when model not available)
  Map<String, dynamic> _generateMockPredictions(String? district, String? grade) {
    final random = Random();
    final basePrice = 1850.0 + (random.nextDouble() * 100 - 50);

    // ✅ Check if we should generate weekly or daily mock data
    final isWeekly = _preprocessingService.isWeeklyModel;
    final forecastPeriods = isWeekly ? 4 : 7;

    final now = DateTime.now();
    final predictions = <Map<String, dynamic>>[];

    double price = basePrice;
    for (int i = 1; i <= forecastPeriods; i++) {
      price += (random.nextDouble() * 80 - 30);

      // ✅ For weekly: add 7 days per period, for daily: add 1 day
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
      'monthlyChange': periodChange, // For weekly model
      'weeklyChange': periodChange,  // For backward compatibility
      'trend': random.nextBool() ? 'upward' : 'downward',
      'district': district ?? 'Unknown',
      'grade': grade ?? 'Unknown',
      'isWeekly': isWeekly,
      'forecastPeriods': forecastPeriods,
    };
  }

  Future<List<List<List<List<double>>>>> _preprocessImageForGrading(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) throw Exception('Failed to decode image');

    final resized = img.copyResize(image, width: 224, height: 224);

    final input = List.generate(
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