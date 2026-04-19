import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/predict_price.dart';
import 'ai_event.dart';
import 'ai_state.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final PredictPrice _predictPrice;

  AiBloc({required PredictPrice predictPrice})
      : _predictPrice = predictPrice,
        super(const AiState()) {
    on<PredictPriceRequested>(_onPredictPriceRequested);
  }

  Future<void> _onPredictPriceRequested(
      PredictPriceRequested event,
      Emitter<AiState> emit,
      ) async {
    emit(state.copyWith(
      status: AiStatus.loading,
      selectedDistrict: event.district,
      selectedGrade: event.grade,
    ));

    final result = await _predictPrice(
      PredictPriceParams(
        district: event.district,
        grade: event.grade,
      ),
    );

    result.fold(
          (failure) => emit(state.copyWith(
        status: AiStatus.failure,
        errorMessage: failure.message,
      )),
          (prediction) => emit(state.copyWith(
        status: AiStatus.success,
        prediction: prediction,
      )),
    );
  }
}