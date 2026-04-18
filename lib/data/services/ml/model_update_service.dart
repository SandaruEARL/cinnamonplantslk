import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model Update Service
/// Uses GitHub + jsdelivr CDN
class ModelUpdateService {

  static const String _keyUpdatedAt = 'model_updated_at';

  // PRIMARY: GitHub Raw URLs (no CDN cache issues)
  static const String _baseUrl =
      'https://raw.githubusercontent.com/SandaruEARL/cinnamon-models/main/models';

  static const String _versionUrl = '$_baseUrl/version.json';
  static const String _modelUrl = '$_baseUrl/latest.tflite';
  static const String _preprocessingUrl = '$_baseUrl/preprocessing.json';
  static const String _recentDataUrl = '$_baseUrl/recent_data.csv';

  // FALLBACK: jsdelivr CDN (faster but can have cache lag)
  static const String _fallbackBaseUrl =
      'https://cdn.jsdelivr.net/gh/SandaruEARL/cinnamon-models@main/models';

  static const String _fallbackVersionUrl = '$_fallbackBaseUrl/version.json';
  static const String _fallbackModelUrl = '$_fallbackBaseUrl/latest.tflite';
  static const String _fallbackPreprocessingUrl = '$_fallbackBaseUrl/preprocessing.json';
  static const String _fallbackRecentDataUrl = '$_fallbackBaseUrl/recent_data.csv';

  // SharedPreferences keys
  static const String _keyCurrentVersion = 'model_current_version';
  static const String _keyLastCheck = 'model_last_check';
  static const String _keyModelHash = 'model_current_hash';

  // Check every 24 hours
  final Duration _checkInterval = const Duration(hours: 24);

  String? getUpdatedAt() => _prefs.getString(_keyUpdatedAt);

  final SharedPreferences _prefs;

  ModelUpdateService(this._prefs);

  /// Check if a model update is available
  Future<ModelUpdateInfo?> checkForUpdate() async {
    try {
      // Rate limiting
      if (!_shouldCheckForUpdate()) {
        debugPrint('⏭️  Skipping check (checked recently)');
        return null;
      }

      debugPrint('🔍 Checking for model updates...');

      // Try jsdelivr CDN first, fallback to GitHub raw
      final remoteVersion = await _fetchRemoteVersion()
          .timeout(const Duration(seconds: 15));

      if (remoteVersion == null) {
        debugPrint('❌ Failed to fetch remote version');
        return null;
      }

      final currentVersion = _prefs.getString(_keyCurrentVersion);
      final currentHash = _prefs.getString(_keyModelHash);

      // Save check time
      await _prefs.setString(_keyLastCheck, DateTime.now().toIso8601String());
      await _prefs.setString(_keyUpdatedAt, remoteVersion.updatedAt);

      // Check if update needed
      if (currentVersion != null &&
          currentVersion == remoteVersion.version &&
          currentHash == remoteVersion.modelHash) {
        debugPrint('✅ Model up to date (v${remoteVersion.version})');
        return null;
      }

      debugPrint('🆕 Update available: v${remoteVersion.version}');
      return ModelUpdateInfo(
        currentVersion: currentVersion,
        newVersion: remoteVersion.version,
        modelSizeKB: remoteVersion.modelSizeKB,
        modelHash: remoteVersion.modelHash,
        updateDate: remoteVersion.updatedAt,
        recordsCount: remoteVersion.recordsCount,
        downloadUrl: _modelUrl,
        fallbackUrl: _fallbackModelUrl,
      );

    } catch (e) {
      debugPrint('⚠️  Error checking update: $e');
      return null;
    }
  }

  /// Download and install model with progress callback
  Future<bool> downloadAndInstallModel(
      ModelUpdateInfo updateInfo, {
        void Function(double progress)? onProgress,
      }) async {
    try {
      debugPrint('📥 Downloading v${updateInfo.newVersion}...');

      final modelFile = await _getLocalModelFile();

      // IMPORTANT: Add cache-busting timestamp to avoid CDN cache issues
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final mainUrl = '${updateInfo.downloadUrl}?_t=$cacheBuster';
      final fallbackUrl = updateInfo.fallbackUrl != null
          ? '${updateInfo.fallbackUrl}?_t=$cacheBuster'
          : null;

      // Try main URL first
      http.Response? response;
      String usedUrl = mainUrl;

      try {
        response = await _downloadWithProgress(
          mainUrl,
          onProgress: onProgress,
        );
      } catch (e) {
        debugPrint('⚠️  Main URL failed: $e');
        if (fallbackUrl != null) {
          debugPrint('🔄 Trying fallback URL...');
          usedUrl = fallbackUrl;
          response = await _downloadWithProgress(
            fallbackUrl,
            onProgress: onProgress,
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode != 200) {
        debugPrint('❌ Download failed: ${response.statusCode}');
        return false;
      }

      final modelBytes = response.bodyBytes;
      debugPrint('📊 Downloaded ${modelBytes.length} bytes from $usedUrl');

      // Calculate hash of downloaded file
      final downloadedHash = sha256.convert(modelBytes).toString();
      debugPrint('🔐 Downloaded hash: $downloadedHash');
      debugPrint('🔐 Expected hash:   ${updateInfo.modelHash}');

      // Verify hash with retries (CDN might be stale)
      if (downloadedHash != updateInfo.modelHash) {
        debugPrint('❌ Hash mismatch on first attempt!');
        debugPrint('   Expected: ${updateInfo.modelHash}');
        debugPrint('   Got:      $downloadedHash');

        // If using CDN, try fallback URL (GitHub raw)
        if (usedUrl.contains('jsdelivr') && fallbackUrl != null) {
          debugPrint('🔄 CDN cache issue detected, trying GitHub raw...');

          try {
            response = await _downloadWithProgress(
              fallbackUrl,
              onProgress: onProgress,
            );

            if (response.statusCode == 200) {
              final retryBytes = response.bodyBytes;
              final retryHash = sha256.convert(retryBytes).toString();

              debugPrint('🔐 Retry hash: $retryHash');

              if (retryHash == updateInfo.modelHash) {
                debugPrint('✅ Hash matched on retry!');
                // Use the retry bytes
                await modelFile.writeAsBytes(retryBytes);
                await _prefs.setString(_keyCurrentVersion, updateInfo.newVersion);
                await _prefs.setString(_keyModelHash, retryHash);
                debugPrint('✅ Model v${updateInfo.newVersion} installed');
                return true;
              }
            }
          } catch (e) {
            debugPrint('⚠️  Retry failed: $e');
          }
        }

        debugPrint('❌ Hash verification failed after all attempts');
        debugPrint('   This usually means:');
        debugPrint('   1. CDN hasn\'t fully propagated (wait 5-10 minutes)');
        debugPrint('   2. version.json and model file are out of sync');
        return false;
      }

      // Save to local storage
      await modelFile.writeAsBytes(modelBytes);

      // Update metadata with actual downloaded hash
      await _prefs.setString(_keyCurrentVersion, updateInfo.newVersion);
      await _prefs.setString(_keyModelHash, downloadedHash);
      await _prefs.setString(_keyUpdatedAt, updateInfo.updateDate);

      debugPrint('✅ Model v${updateInfo.newVersion} installed');
      return true;

    } catch (e, stackTrace) {
      debugPrint('⚠️  Download error: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Download with progress tracking
  Future<http.Response> _downloadWithProgress(
      String url, {
        void Function(double progress)? onProgress,
      }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await client.send(request)
          .timeout(const Duration(seconds: 60));

      if (streamedResponse.statusCode != 200) {
        throw Exception('HTTP ${streamedResponse.statusCode}');
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final bytes = <int>[];
      int received = 0;

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;

        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      }

      return http.Response.bytes(bytes, streamedResponse.statusCode);
    } finally {
      client.close();
    }
  }

  /// Get local model file
  Future<File> getModelFile() async {
    return await _getLocalModelFile();
  }


  /// Download preprocessing.json
  Future<bool> downloadPreprocessing() async {
    try {
      debugPrint('📥 Downloading preprocessing.json...');

      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      http.Response? response;

      try {
        response = await http.get(Uri.parse('$_preprocessingUrl?_=$cacheBuster'))
            .timeout(const Duration(seconds: 30));
      } catch (e) {
        debugPrint('⚠️  Main URL failed, trying fallback...');
        response = await http.get(Uri.parse('$_fallbackPreprocessingUrl?_=$cacheBuster'))
            .timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        final file = await _getPreprocessingFile();
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Preprocessing downloaded');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️  Failed to download preprocessing: $e');
      return false;
    }
  }

  /// Download recent_data.csv
  Future<bool> downloadRecentData() async {
    try {
      debugPrint('📥 Downloading recent_data.csv...');

      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      http.Response? response;

      try {
        response = await http.get(Uri.parse('$_recentDataUrl?_=$cacheBuster'))
            .timeout(const Duration(seconds: 30));
      } catch (e) {
        debugPrint('⚠️  Main URL failed, trying fallback...');
        response = await http.get(Uri.parse('$_fallbackRecentDataUrl?_=$cacheBuster'))
            .timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        final file = await _getRecentDataFile();
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Recent data downloaded (${response.bodyBytes.length} bytes)');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️  Failed to download recent data: $e');
      return false;
    }
  }

  /// Get preprocessing file
  Future<File> _getPreprocessingFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/models');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return File('${modelDir.path}/preprocessing.json');
  }

  /// Get recent data file
  Future<File> _getRecentDataFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/models');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return File('${modelDir.path}/recent_data.csv');
  }

  /// Get current version
  Future<String?> getCurrentVersion() async {
    return _prefs.getString(_keyCurrentVersion);
  }

  /// Force check (bypass rate limiting)
  Future<ModelUpdateInfo?> forceCheckForUpdate() async {
    await _prefs.remove(_keyLastCheck);
    return checkForUpdate();
  }

  /// Clear model data
  Future<void> clearModelData() async {
    await _prefs.remove(_keyCurrentVersion);
    await _prefs.remove(_keyLastCheck);
    await _prefs.remove(_keyModelHash);

    final modelFile = await _getLocalModelFile();
    if (await modelFile.exists()) {
      await modelFile.delete();
    }

    debugPrint('🗑️  Model data cleared');
  }

  // Private helpers

  bool _shouldCheckForUpdate() {
    final lastCheckStr = _prefs.getString(_keyLastCheck);
    if (lastCheckStr == null) return true;

    final lastCheck = DateTime.parse(lastCheckStr);
    final timeSinceCheck = DateTime.now().difference(lastCheck);

    return timeSinceCheck >= _checkInterval;
  }

  Future<RemoteVersionInfo?> _fetchRemoteVersion() async {
    // Try GitHub raw first (no cache issues)
    try {
      debugPrint('📡 Trying GitHub raw...');
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$_versionUrl?_=$cacheBuster'),
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Got version from GitHub raw');
        final json = jsonDecode(response.body);
        return RemoteVersionInfo.fromJson(json);
      }
    } catch (e) {
      debugPrint('⚠️  GitHub raw failed: $e');
    }

    // Fallback to jsdelivr CDN
    try {
      debugPrint('📡 Trying jsdelivr CDN...');
      final cacheBuster = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$_fallbackVersionUrl?_=$cacheBuster'),
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Got version from jsdelivr CDN');
        final json = jsonDecode(response.body);
        return RemoteVersionInfo.fromJson(json);
      }
    } catch (e) {
      debugPrint('⚠️  jsdelivr CDN failed: $e');
    }

    return null;
  }

  Future<File> _getLocalModelFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/models');

    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    return File('${modelDir.path}/price_predictor.tflite');
  }
}

class ModelUpdateInfo {
  final String? currentVersion;
  final String newVersion;
  final double modelSizeKB;
  final String modelHash;
  final String updateDate;
  final int recordsCount;
  final String downloadUrl;
  final String? fallbackUrl;

  ModelUpdateInfo({
    this.currentVersion,
    required this.newVersion,
    required this.modelSizeKB,
    required this.modelHash,
    required this.updateDate,
    required this.recordsCount,
    required this.downloadUrl,
    this.fallbackUrl,
  });

  bool get isFirstInstall => currentVersion == null;
  String get sizeFormatted => '${modelSizeKB.toStringAsFixed(1)} KB';
}

class RemoteVersionInfo {
  final String version;
  final String updatedAt;
  final String modelHash;
  final double modelSizeKB;
  final int recordsCount;

  RemoteVersionInfo({
    required this.version,
    required this.updatedAt,
    required this.modelHash,
    required this.modelSizeKB,
    required this.recordsCount,
  });

  factory RemoteVersionInfo.fromJson(Map<String, dynamic> json) {
    return RemoteVersionInfo(
      version: json['version'] as String,
      updatedAt: json['updated_at'] as String,
      modelHash: json['model_hash'] as String,
      modelSizeKB: (json['model_size_kb'] as num).toDouble(),
      recordsCount: json['records_count'] as int? ?? 0,
    );
  }
}