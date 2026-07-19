import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/unit_banking_repository.dart';
import '../../domain/usecases/get_unit_banking_summary.dart';
import 'unit_banking_event.dart';
import 'unit_banking_state.dart';

class UnitBankingBloc extends Bloc<UnitBankingEvent, UnitBankingState> {
  final GetUnitBankingSummary _getSummary;
  final UnitBankingRepository _repository;

  UnitBankingBloc(this._getSummary, this._repository)
      : super(const UnitBankingInitial()) {
    on<UnitBankingLoadRequested>(_onLoad);
    on<UnitBankingFreezeCard>(_onFreezeCard);
    on<UnitBankingUnfreezeCard>(_onUnfreezeCard);
    on<UnitBankingCreateAccount>(_onCreateAccount);
  }

  Future<void> _onLoad(
    UnitBankingLoadRequested event,
    Emitter<UnitBankingState> emit,
  ) async {
    emit(const UnitBankingLoading());
    try {
      final summary = await _getSummary();
      emit(UnitBankingLoaded(summary));
    } catch (e) {
      emit(UnitBankingError(e.toString()));
    }
  }

  Future<void> _onFreezeCard(
    UnitBankingFreezeCard event,
    Emitter<UnitBankingState> emit,
  ) async {
    emit(const UnitBankingLoading());
    try {
      await _repository.freezeCard(event.unitCardId);
      final summary = await _getSummary();
      emit(UnitBankingActionSuccess(message: 'Card frozen', summary: summary));
    } catch (e) {
      emit(UnitBankingError(e.toString()));
    }
  }

  Future<void> _onUnfreezeCard(
    UnitBankingUnfreezeCard event,
    Emitter<UnitBankingState> emit,
  ) async {
    emit(const UnitBankingLoading());
    try {
      await _repository.unfreezeCard(event.unitCardId);
      final summary = await _getSummary();
      emit(UnitBankingActionSuccess(message: 'Card unfrozen', summary: summary));
    } catch (e) {
      emit(UnitBankingError(e.toString()));
    }
  }

  Future<void> _onCreateAccount(
    UnitBankingCreateAccount event,
    Emitter<UnitBankingState> emit,
  ) async {
    emit(const UnitBankingLoading());
    try {
      await _repository.createAccount();
      final summary = await _getSummary();
      emit(UnitBankingActionSuccess(
          message: 'Account created successfully', summary: summary));
    } catch (e) {
      emit(UnitBankingError(e.toString()));
    }
  }
}
