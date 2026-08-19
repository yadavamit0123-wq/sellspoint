import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/data/repositories/system_repository.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CurrenciesState {}

class CurrenciesInitial extends CurrenciesState {}

class CurrenciesLoading extends CurrenciesState {}

class CurrenciesSuccess extends CurrenciesState {
  final List<Currency> currencies;

  CurrenciesSuccess(this.currencies);
}

class CurrenciesFailure extends CurrenciesState {
  final String errorMessage;

  CurrenciesFailure(this.errorMessage);
}

class CurrenciesCubit extends Cubit<CurrenciesState> {
  CurrenciesCubit() : super(CurrenciesInitial());

  Currency getSelectedCurrency() {
    if (state case final CurrenciesSuccess s when s.currencies.isNotEmpty) {
      return s.currencies.firstWhere(
        (c) => c.selected,
        orElse: () => s.currencies.first,
      );
    } else {
      return Constant.systemSettings.defaultCurrency;
    }
  }

  Future<void> fetchCurrencies() async {
    try {
      emit(CurrenciesLoading());
      final currencies = await SystemRepository.instance.getCurrencies();
      emit(CurrenciesSuccess(currencies));
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(CurrenciesFailure(e.toString()));
    }
  }
}
