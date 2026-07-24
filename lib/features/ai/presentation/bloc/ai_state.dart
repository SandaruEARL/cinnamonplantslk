import 'package:equatable/equatable.dart';
import '../../domain/entities/weekly_prediction_entity.dart';

enum AiStatus { initial, loading, success, failure }

class AiState extends Equatable {
  final AiStatus status;
  final PricePredictionEntity? prediction;
  final String? errorMessage;
  final String? selectedDistrict;
  final String? selectedGrade;

  const AiState({
    this.status = AiStatus.initial,
    this.prediction,
    this.errorMessage,
    this.selectedDistrict,
    this.selectedGrade,
  });

  AiState copyWith({
    AiStatus? status,
    PricePredictionEntity? prediction,
    String? errorMessage,
    String? selectedDistrict,
    String? selectedGrade,
  }) {
    return AiState(
      status: status ?? this.status,
      prediction: prediction ?? this.prediction,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      selectedGrade: selectedGrade ?? this.selectedGrade,
    );
  }

  @override
  List<Object?> get props => [
    status,
    prediction,
    errorMessage,
    selectedDistrict,
    selectedGrade,
  ];
}