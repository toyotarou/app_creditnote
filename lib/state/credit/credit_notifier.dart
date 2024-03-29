import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../collections/credit.dart';
import 'credit_response_state.dart';

final creditProvider = StateNotifierProvider.autoDispose<CreditNotifier, CreditResponseState>((ref) {
  final dates = List.generate(10, (index) => '');
  final names = List.generate(10, (index) => '');
  final prices = List.generate(10, (index) => -1);

  return CreditNotifier(CreditResponseState(creditDates: dates, creditNames: names, creditPrices: prices));
});

class CreditNotifier extends StateNotifier<CreditResponseState> {
  CreditNotifier(super.state);

  ///
  Future<void> setItemPos({required int pos}) async => state = state.copyWith(itemPos: pos);

  ///
  Future<void> setCreditDate({required int pos, required String date}) async {
    final dates = <String>[...state.creditDates];
    dates[pos] = date;
    state = state.copyWith(creditDates: dates);
  }

  ///
  Future<void> setCreditName({required int pos, required String name}) async {
    final names = <String>[...state.creditNames];
    names[pos] = name;
    state = state.copyWith(creditNames: names);
  }

  ///
  Future<void> setCreditPrice({required int pos, required int price}) async {
    final prices = <int>[...state.creditPrices];
    prices[pos] = price;
    state = state.copyWith(creditPrices: prices);
  }

  ///
  Future<void> clearInputValue() async {
    final dates = List.generate(10, (index) => '');
    final names = List.generate(10, (index) => '');
    final prices = List.generate(10, (index) => 0);

    state = state.copyWith(creditDates: dates, creditNames: names, creditPrices: prices);
  }

  ///
  Future<void> setUpdateCredit({required List<Credit> updateCredit}) async {
    try {
      final dates = <String>[...state.creditDates];
      final names = <String>[...state.creditNames];
      final prices = <int>[...state.creditPrices];

      for (var i = 0; i < updateCredit.length; i++) {
        dates[i] = updateCredit[i].date;
        names[i] = updateCredit[i].name;
        prices[i] = updateCredit[i].price;
      }

      state = state.copyWith(creditDates: dates, creditNames: names, creditPrices: prices);

      // ignore: avoid_catches_without_on_clauses, empty_catches
    } catch (e) {}
  }

  ///
  Future<void> clearOneBox({required int pos}) async {
    final dates = <String>[...state.creditDates];
    final names = <String>[...state.creditNames];
    final prices = <int>[...state.creditPrices];

    dates[pos] = '';
    names[pos] = '';
    prices[pos] = -1;

    state = state.copyWith(creditDates: dates, creditNames: names, creditPrices: prices);
  }
}
