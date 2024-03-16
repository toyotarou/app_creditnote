import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/credit_blank_input_value.dart';
import 'credit_blank_response_state.dart';

final creditBlankProvider = StateNotifierProvider.autoDispose<CreditBlankNotifier, CreditBlankResponseState>((ref) {
  final values = List.generate(100, (index) => CreditBlankInputValue(-1, '', -1));
  return CreditBlankNotifier(CreditBlankResponseState(creditBlankInputValues: values));
});

class CreditBlankNotifier extends StateNotifier<CreditBlankResponseState> {
  CreditBlankNotifier(super.state);

  ///
  Future<void> setSelectedCreditBlankInputValues({required int pos, required CreditBlankInputValue value}) async {
    final values = [...state.creditBlankInputValues];
    values[pos] = value;
    state = state.copyWith(creditBlankInputValues: values);
  }
}
