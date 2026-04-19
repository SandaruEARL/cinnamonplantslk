import '../../../../data/services/ai/tflite_service.dart';

abstract class AiLocalDatasource {
  Future<Map<String, dynamic>> predictPrice({
    required String district,
    required String grade,
  });

  Future<void> ensureModelReady();

  String? getModelUpdatedAt();
}

class AiLocalDatasourceImpl implements AiLocalDatasource {
  final TFLiteService _tfliteService;

  const AiLocalDatasourceImpl(this._tfliteService);

  @override
  Future<void> ensureModelReady() async {
    if (_tfliteService.getModelUpdatedAt() == null) {
      await _tfliteService.checkForModelUpdate();
    }
  }

  @override
  Future<Map<String, dynamic>> predictPrice({
    required String district,
    required String grade,
  }) async {
    await ensureModelReady();
    return _tfliteService.predictPrices(
      district: district,
      grade: grade,
    );
  }

  @override
  String? getModelUpdatedAt() => _tfliteService.getModelUpdatedAt();
}