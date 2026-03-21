import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Handles ML preprocessing (scaling, encoding, feature engineering)
/// ✅ UPDATED: Supports both WEEKLY and DAILY models
class MLPreprocessingService {
  Map<String, dynamic>? _preprocessing;
  List<Map<String, dynamic>>? _recentData;

  bool get isLoaded => _preprocessing != null && _recentData != null;

  /// ✅ NEW: Check if model is weekly or daily
  bool get isWeeklyModel {
    if (_preprocessing == null) return false;
    return _preprocessing!['data_frequency'] == 'weekly';
  }

  /// ✅ NEW: Get lookback period (weeks or days)
  int get lookbackPeriods {
    if (_preprocessing == null) return 30;
    if (isWeeklyModel) {
      return _preprocessing!['lookback_weeks'] ?? 12;
    } else {
      return _preprocessing!['lookback_days'] ?? 30;
    }
  }

  /// ✅ NEW: Get forecast period (weeks or days)
  int get forecastPeriods {
    if (_preprocessing == null) return 7;
    if (isWeeklyModel) {
      return _preprocessing!['forecast_weeks'] ?? 4;
    } else {
      return _preprocessing!['forecast_days'] ?? 7;
    }
  }

  /// Normalize grade names to match CSV format
  String _normalizeGrade(String grade) {
    final mapping = {
      'C5 Special': 'C-5 Sp',
      'C5': 'C-5',
      'C4': 'C-4',
      'M5': 'M-5',
      'M4': 'M-4',
      'H1': 'H-1',
      'H2': 'H-2',
      'Alba': 'Alba',
    };

    return mapping[grade] ?? grade;
  }

  /// Load preprocessing.json
  Future<bool> loadPreprocessing() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/models/preprocessing.json');

      if (!await file.exists()) {
        debugPrint('⚠️  preprocessing.json not found');
        return false;
      }

      final jsonStr = await file.readAsString();
      _preprocessing = jsonDecode(jsonStr);

      debugPrint('✅ Loaded preprocessing.json');
      debugPrint('   Features: ${_preprocessing!['num_features']}');
      debugPrint('   Districts: ${_preprocessing!['district_encoder']['classes'].length}');
      debugPrint('   Grades: ${_preprocessing!['grade_encoder']['classes'].length}');
      debugPrint('   Model type: ${isWeeklyModel ? 'WEEKLY' : 'DAILY'}'); // ✅ NEW
      if (isWeeklyModel) {
        debugPrint('   Lookback: ${lookbackPeriods} weeks');
        debugPrint('   Forecast: ${forecastPeriods} weeks');
      } else {
        debugPrint('   Lookback: ${lookbackPeriods} days');
        debugPrint('   Forecast: ${forecastPeriods} days');
      }

      return true;
    } catch (e) {
      debugPrint('⚠️  Failed to load preprocessing: $e');
      return false;
    }
  }

  /// Load recent_data.csv
  Future<bool> loadRecentData() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/models/recent_data.csv');

      if (!await file.exists()) {
        debugPrint('⚠️  recent_data.csv not found');
        return false;
      }

      final csvStr = await file.readAsString();
      final lines = csvStr.split('\n');

      if (lines.isEmpty) {
        debugPrint('⚠️  CSV is empty');
        return false;
      }

      final firstLine = lines[0];
      final separator = firstLine.contains('\t') ? '\t' : ',';

      debugPrint('📄 CSV separator detected: ${separator == '\t' ? 'TAB' : 'COMMA'}');

      final headers = lines[0].split(separator).map((h) => h.trim()).toList();
      _recentData = [];

      debugPrint('📋 CSV Headers: $headers');

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;

        final values = lines[i].split(separator).map((v) => v.trim()).toList();

        if (values.length != headers.length) {
          debugPrint('⚠️ Skipping malformed row $i: expected ${headers.length} columns, got ${values.length}');
          continue;
        }

        final row = <String, dynamic>{};

        for (int j = 0; j < headers.length; j++) {
          row[headers[j]] = values[j];
        }

        _recentData!.add(row);
      }

      debugPrint('✅ Loaded recent_data.csv');
      debugPrint('   Records: ${_recentData!.length}');
      debugPrint('   Expected: ${lookbackPeriods} ${isWeeklyModel ? 'weeks' : 'days'} per district/grade'); // ✅ NEW

      if (_recentData!.isNotEmpty) {
        debugPrint('   Sample row: ${_recentData![0]}');

        final districts = _recentData!.map((r) => r['district']).toSet();
        final grades = _recentData!.map((r) => r['grade']).toSet();
        debugPrint('   Unique districts: $districts');
        debugPrint('   Unique grades: $grades');
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('⚠️  Failed to load recent data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get current market price (last known price from data)
  double getCurrentPrice({
    required String district,
    required String grade,
  }) {
    if (!isLoaded) {
      throw Exception('Preprocessing not loaded');
    }

    final normalizedGrade = _normalizeGrade(grade);

    final filtered = _recentData!.where((row) {
      return row['district'] == district && row['grade'] == normalizedGrade;
    }).toList();

    if (filtered.isEmpty) {
      throw Exception('No data found for $district + $normalizedGrade');
    }

    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    final lastRecord = filtered.last;
    final currentPrice = double.parse(lastRecord['average_price_rs_kg'].toString());

    debugPrint('💵 Current market price from data:');
    debugPrint('   District: $district, Grade: $normalizedGrade');
    debugPrint('   Date: ${lastRecord['date']}');
    debugPrint('   Price: Rs. ${currentPrice.toStringAsFixed(2)}');

    return currentPrice;
  }

  /// Denormalize price predictions back to actual values
  List<double> denormalizePrices(List<double> normalizedPrices, String priceColumn) {
    if (!isLoaded) {
      throw Exception('Preprocessing not loaded');
    }

    final featureColumns = List<String>.from(_preprocessing!['feature_columns']);
    final priceIndex = featureColumns.indexOf(priceColumn);

    if (priceIndex == -1) {
      debugPrint('⚠️ Price column not found: $priceColumn');
      debugPrint('   Available columns: $featureColumns');
      throw Exception('Price column not found: $priceColumn');
    }

    final minValues = List<double>.from(_preprocessing!['scaler']['min_values']);
    final maxValues = List<double>.from(_preprocessing!['scaler']['max_values']);

    final min = minValues[priceIndex];
    final max = maxValues[priceIndex];
    final range = max - min;

    debugPrint('🔄 Denormalizing prices:');
    debugPrint('   Column: $priceColumn (index $priceIndex)');
    debugPrint('   Min: $min, Max: $max, Range: $range');

    return normalizedPrices.map((normalized) {
      final actual = (normalized * range) + min;
      return actual;
    }).toList();
  }

  /// Prepare input for model
  /// ✅ UPDATED: Works with both weekly (12 weeks) and daily (30 days) models
  List<List<List<double>>> prepareInput({
    required String district,
    required String grade,
  }) {
    if (!isLoaded) {
      throw Exception('Preprocessing not loaded');
    }

    final normalizedGrade = _normalizeGrade(grade);
    final requiredRecords = lookbackPeriods; // 12 weeks or 30 days

    debugPrint('🔍 Filtering data for ${isWeeklyModel ? 'WEEKLY' : 'DAILY'} model:');
    debugPrint('   District: $district');
    debugPrint('   Grade (input): $grade');
    debugPrint('   Grade (normalized): $normalizedGrade');
    debugPrint('   Required records: $requiredRecords ${isWeeklyModel ? 'weeks' : 'days'}');

    // Filter data for specific district + grade
    final filtered = _recentData!.where((row) {
      return row['district'] == district && row['grade'] == normalizedGrade;
    }).toList();

    debugPrint('   Filtered records: ${filtered.length}');

    if (filtered.length < requiredRecords) {
      if (filtered.isEmpty) {
        debugPrint('❌ No data found for $district + $normalizedGrade');
        debugPrint('   Available combinations:');
        final combos = _recentData!
            .map((r) => '${r['district']} + ${r['grade']}')
            .toSet()
            .take(10);
        for (final combo in combos) {
          debugPrint('   - $combo');
        }
      }
      throw Exception('Not enough historical data (need $requiredRecords, have ${filtered.length})');
    }

    // Sort by date to ensure chronological order
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    // Take last N records (weeks or days)
    final lastN = filtered.sublist(math.max(0, filtered.length - requiredRecords));

    debugPrint('✅ Using last $requiredRecords records from ${lastN.first['date']} to ${lastN.last['date']}');

    // Encode district and grade
    final districtEncoded = _encodeDistrict(district);
    final gradeEncoded = _encodeGrade(normalizedGrade);

    // Build features for each period
    final inputSequence = <List<double>>[];

    for (int i = 0; i < requiredRecords; i++) {
      final row = lastN[i];
      final features = _extractFeatures(row, districtEncoded, gradeEncoded, i, lastN);
      inputSequence.add(features);
    }

    // Normalize using scaler
    final normalized = _normalizeFeatures(inputSequence);

    // Shape: [1, lookbackPeriods, features] for TFLite
    return [normalized];
  }

  /// Extract features from a row
  /// ✅ This works for BOTH weekly and daily models (same feature structure)
  List<double> _extractFeatures(
      Map<String, dynamic> row,
      int districtEncoded,
      int gradeEncoded,
      int index,
      List<Map<String, dynamic>> historicalData,
      ) {
    final features = <double>[];

    // Parse date
    final dateParts = row['date'].toString().split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final date = DateTime(year, month, day);

    // 1-2: Categorical encodings
    features.add(districtEncoded.toDouble());
    features.add(gradeEncoded.toDouble());

    // 3-8: Time features (same for weekly and daily)
    features.add(year.toDouble());
    features.add(month.toDouble());
    if (isWeeklyModel) {
      // For weekly model: use week_of_year (no day field)
      features.add(_weekOfYear(date).toDouble());
    } else {
      // For daily model: use day and day_of_week
      features.add(day.toDouble());
      features.add(date.weekday.toDouble());
      features.add(_weekOfYear(date).toDouble());
    }
    features.add(((month - 1) ~/ 3 + 1).toDouble()); // quarter

    // 9-12: Cyclical encodings
    features.add(math.sin(2 * math.pi * month / 12));
    features.add(math.cos(2 * math.pi * month / 12));
    if (isWeeklyModel) {
      // For weekly model: week cyclical encoding
      features.add(math.sin(2 * math.pi * _weekOfYear(date) / 52));
      features.add(math.cos(2 * math.pi * _weekOfYear(date) / 52));
    } else {
      // For daily model: day cyclical encoding
      features.add(math.sin(2 * math.pi * date.weekday / 7));
      features.add(math.cos(2 * math.pi * date.weekday / 7));
    }

    // 13-14: Current prices
    final avgPrice = double.parse(row['average_price_rs_kg'].toString());
    final highPrice = double.parse(row['highest_price_rs_kg'].toString());
    features.add(avgPrice);
    features.add(highPrice);

    // 15-22: Lag features (adapted for weekly/daily)
    if (isWeeklyModel) {
      // Weekly lags: 1, 4, 8, 12 weeks
      features.add(_getLag(historicalData, index, 1, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 1, 'highest_price_rs_kg'));
      features.add(_getLag(historicalData, index, 4, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 4, 'highest_price_rs_kg'));
      features.add(_getLag(historicalData, index, 8, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 8, 'highest_price_rs_kg'));
      features.add(_getLag(historicalData, index, 12, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 12, 'highest_price_rs_kg'));
    } else {
      // Daily lags: 1, 7, 14, 30 days
      features.add(_getLag(historicalData, index, 1, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 1, 'highest_price_rs_kg'));
      features.add(_getLag(historicalData, index, 7, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 7, 'highest_price_rs_kg'));
      features.add(_getLag(historicalData, index, 14, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 14, 'highest_price_rs_kg'));
      features.add(_getLag(historicalData, index, 30, 'average_price_rs_kg'));
      features.add(_getLag(historicalData, index, 30, 'highest_price_rs_kg'));
    }

    // 23-28: Rolling statistics (adapted for weekly/daily)
    if (isWeeklyModel) {
      // Weekly windows: 4, 8, 12 weeks
      features.add(_rollingMean(historicalData, index, 4, 'average_price_rs_kg'));
      features.add(_rollingStd(historicalData, index, 4, 'average_price_rs_kg'));
      features.add(_rollingMean(historicalData, index, 8, 'average_price_rs_kg'));
      features.add(_rollingStd(historicalData, index, 8, 'average_price_rs_kg'));
      features.add(_rollingMean(historicalData, index, 12, 'average_price_rs_kg'));
      features.add(_rollingStd(historicalData, index, 12, 'average_price_rs_kg'));
    } else {
      // Daily windows: 7, 14, 30 days
      features.add(_rollingMean(historicalData, index, 7, 'average_price_rs_kg'));
      features.add(_rollingStd(historicalData, index, 7, 'average_price_rs_kg'));
      features.add(_rollingMean(historicalData, index, 14, 'average_price_rs_kg'));
      features.add(_rollingStd(historicalData, index, 14, 'average_price_rs_kg'));
      features.add(_rollingMean(historicalData, index, 30, 'average_price_rs_kg'));
      features.add(_rollingStd(historicalData, index, 30, 'average_price_rs_kg'));
    }

    // 29-30: Price momentum (adapted for weekly/daily)
    if (isWeeklyModel) {
      // Weekly momentum: 4 weeks, 12 weeks
      features.add(_priceChange(historicalData, index, 4, 'average_price_rs_kg'));
      features.add(_priceChange(historicalData, index, 12, 'average_price_rs_kg'));
    } else {
      // Daily momentum: 7 days, 30 days
      features.add(_priceChange(historicalData, index, 7, 'average_price_rs_kg'));
      features.add(_priceChange(historicalData, index, 30, 'average_price_rs_kg'));
    }

    // Verify feature count (should match num_features in preprocessing.json)
    final expectedFeatures = _preprocessing!['num_features'] as int;
    if (features.length != expectedFeatures) {
      debugPrint('⚠️ Feature count mismatch: ${features.length} != $expectedFeatures');
      throw Exception('Feature extraction error: expected $expectedFeatures features, got ${features.length}');
    }

    return features;
  }

  /// Encode district to integer
  int _encodeDistrict(String district) {
    final mapping = _preprocessing!['district_encoder']['mapping'];
    return mapping[district] ?? 0;
  }

  /// Encode grade to integer
  int _encodeGrade(String grade) {
    final mapping = _preprocessing!['grade_encoder']['mapping'];
    return mapping[grade] ?? 0;
  }

  /// Get week of year
  int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).floor() + 1;
  }

  /// Get lagged value
  double _getLag(List<Map<String, dynamic>> data, int index, int lag, String column) {
    final lagIndex = index - lag;
    if (lagIndex < 0 || lagIndex >= data.length) return 0.0;
    try {
      return double.parse(data[lagIndex][column].toString());
    } catch (e) {
      debugPrint('⚠️ Error parsing lag: $e');
      return 0.0;
    }
  }

  /// Calculate rolling mean
  double _rollingMean(List<Map<String, dynamic>> data, int index, int window, String column) {
    final start = math.max(0, index - window + 1);
    final end = index + 1;

    if (start >= data.length) return 0.0;

    try {
      final values = data
          .sublist(start, math.min(end, data.length))
          .map((r) => double.parse(r[column].toString()))
          .toList();

      if (values.isEmpty) return 0.0;
      return values.reduce((a, b) => a + b) / values.length;
    } catch (e) {
      debugPrint('⚠️ Error calculating rolling mean: $e');
      return 0.0;
    }
  }

  /// Calculate rolling std
  double _rollingStd(List<Map<String, dynamic>> data, int index, int window, String column) {
    final start = math.max(0, index - window + 1);
    final end = index + 1;

    if (start >= data.length) return 0.0;

    try {
      final values = data
          .sublist(start, math.min(end, data.length))
          .map((r) => double.parse(r[column].toString()))
          .toList();

      if (values.isEmpty || values.length == 1) return 0.0;

      final mean = values.reduce((a, b) => a + b) / values.length;
      final variance = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
      return math.sqrt(variance);
    } catch (e) {
      debugPrint('⚠️ Error calculating rolling std: $e');
      return 0.0;
    }
  }

  /// Calculate price change percentage
  double _priceChange(List<Map<String, dynamic>> data, int index, int periods, String column) {
    if (index - periods < 0 || index >= data.length) return 0.0;

    try {
      final current = double.parse(data[index][column].toString());
      final past = double.parse(data[index - periods][column].toString());

      if (past == 0) return 0.0;
      return (current - past) / past;
    } catch (e) {
      debugPrint('⚠️ Error calculating price change: $e');
      return 0.0;
    }
  }

  /// Normalize features using MinMaxScaler
  List<List<double>> _normalizeFeatures(List<List<double>> features) {
    final minValues = List<double>.from(_preprocessing!['scaler']['min_values']);
    final maxValues = List<double>.from(_preprocessing!['scaler']['max_values']);

    final normalized = <List<double>>[];

    for (final row in features) {
      final normalizedRow = <double>[];

      for (int i = 0; i < row.length; i++) {
        final min = minValues[i];
        final max = maxValues[i];
        final range = max - min;

        if (range == 0) {
          normalizedRow.add(0.0);
        } else {
          normalizedRow.add((row[i] - min) / range);
        }
      }

      normalized.add(normalizedRow);
    }

    return normalized;
  }
}