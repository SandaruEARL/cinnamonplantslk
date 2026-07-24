import 'package:equatable/equatable.dart';

abstract class AiEvent extends Equatable {
  const AiEvent();

  @override
  List<Object?> get props => [];
}

class PredictPriceRequested extends AiEvent {
  final String district;
  final String grade;

  const PredictPriceRequested({
    required this.district,
    required this.grade,
  });

  @override
  List<Object?> get props => [district, grade];
}