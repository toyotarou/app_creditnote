import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../collections/credit.dart';
import '../../collections/credit_detail.dart';
import '../../extensions/extensions.dart';
import '../../repository/credit_details_repository.dart';
import '../../repository/credits_repository.dart';
import '../../state/app_params/app_params_notifier.dart';
import '../../state/credit/credit_notifier.dart';
import '../../utility/function.dart';
import 'credit_blank_re_input_alert.dart';
import 'parts/credit_dialog.dart';
import 'parts/error_dialog.dart';

class CreditInputAlert extends ConsumerStatefulWidget {
  const CreditInputAlert({super.key, required this.isar, required this.date, this.creditList, required this.creditBlankCreditDetailList});

  final Isar isar;
  final DateTime date;
  final List<Credit>? creditList;

  final List<CreditDetail> creditBlankCreditDetailList;

  @override
  ConsumerState<CreditInputAlert> createState() => _CreditInputAlertState();
}

class _CreditInputAlertState extends ConsumerState<CreditInputAlert> {
  final List<TextEditingController> _creditNameTecs = [];
  final List<TextEditingController> _creditPriceTecs = [];

  List<Credit> deleteCreditList = [];

  ///
  @override
  void initState() {
    super.initState();

    _makeTecs();
  }

  ///
  Future<void> _makeTecs() async {
    for (var i = 0; i < 10; i++) {
      _creditNameTecs.add(TextEditingController(text: ''));
      _creditPriceTecs.add(TextEditingController(text: ''));
    }

    if (widget.creditList!.isNotEmpty) {
      await Future(() => ref.read(creditProvider.notifier).setUpdateCredit(updateCredit: widget.creditList!));

      for (var i = 0; i < widget.creditList!.length; i++) {
        _creditNameTecs[i].text = widget.creditList![i].name.trim();
        _creditPriceTecs[i].text = widget.creditList![i].price.toString().trim();
      }
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    final inputButtonClicked = ref.watch(appParamProvider.select((value) => value.inputButtonClicked));

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const Text('Credit Input'), Text(widget.date.yyyymm)],
                  ),
                  ElevatedButton(
                    onPressed: inputButtonClicked
                        ? null
                        : () {
                            ref.read(appParamProvider.notifier).setInputButtonClicked(flag: true);

                            _inputCredit();
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent.withOpacity(0.2)),
                    child: const Text('input'),
                  ),
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              if (widget.creditBlankCreditDetailList.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'クレジットカードに紐づいていない当月の詳細情報が存在します。',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        ref.read(appParamProvider.notifier).setInputButtonClicked(flag: false);

                        ref.read(appParamProvider.notifier).setCreditBlankDefaultMap();

                        CreditDialog(
                          context: context,
                          widget: CreditBlankReInputAlert(
                            isar: widget.isar,
                            date: widget.date,
                            creditList: widget.creditList,
                            creditBlankCreditDetailList: widget.creditBlankCreditDetailList,
                          ),
                        );
                      },
                      child: Icon(Icons.info_outline, color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              Expanded(child: _displayInputParts()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayInputParts() {
    final list = <Widget>[];

    final creditInputState = ref.watch(creditProvider);

    for (var i = 0; i < 10; i++) {
      final date = creditInputState.creditDates[i];
      final name = creditInputState.creditNames[i];
      final price = creditInputState.creditPrices[i];

      list.add(DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 24, spreadRadius: 16, color: Colors.black.withOpacity(0.2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Stack(
              children: [
                Positioned(
                  bottom: 5,
                  right: 15,
                  child: Text(
                    (i + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 60,
                      color: (date != '' && name != '' && price != -1) ? Colors.orangeAccent.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                Container(
                  width: context.screenSize.width,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: (date != '' && name != '' && price != -1) ? Colors.orangeAccent.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                        width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showDP(pos: i),
                                child: Icon(Icons.calendar_month, color: Colors.greenAccent.withOpacity(0.6)),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(width: context.screenSize.width / 6, child: Text(date, style: const TextStyle(fontSize: 10))),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              _addingDeleteCreditList(date: date, price: price);

                              _clearOneBox(pos: i);
                            },
                            child: const Icon(Icons.close, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _creditNameTecs[i],
                              decoration: const InputDecoration(labelText: 'クレジット名(15文字以内)'),
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                              onChanged: (value) {
                                if (value != '') {
                                  ref.read(creditProvider.notifier).setCreditName(pos: i, name: value.trim());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: _creditPriceTecs[i],
                              decoration: const InputDecoration(labelText: '金額(10桁以内)'),
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                              onChanged: (value) {
                                if (value != '') {
                                  ref.read(creditProvider.notifier).setCreditPrice(pos: i, price: value.trim().toInt());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return SingleChildScrollView(child: Column(children: list));
  }

  ///
  Future<void> _showDP({required int pos}) async {
    final selectedDate = await showDatePicker(
      barrierColor: Colors.transparent,
      locale: const Locale('ja'),
      context: context,
      initialDate: DateTime(widget.date.year, widget.date.month),
      firstDate: DateTime(widget.date.year, widget.date.month),
      lastDate: DateTime(widget.date.year, widget.date.month + 1, 0),
    );

    if (selectedDate != null) {
      await ref.read(creditProvider.notifier).setCreditDate(pos: pos, date: selectedDate.yyyymmdd);
    }
  }

  ///
  Future<void> _inputCredit() async {
    final creditInputState = ref.watch(creditProvider);

    final list = <Credit>[];

    var errFlg = false;

    ////////////////////////// 同数チェック
    var creditDateCount = 0;
    var creditNameCount = 0;
    var creditPriceCount = 0;
    ////////////////////////// 同数チェック

    for (var i = 0; i < 10; i++) {
      if (creditInputState.creditDates[i] != '' && creditInputState.creditNames[i] != '' && creditInputState.creditPrices[i] > -1) {
        list.add(
          Credit()
            ..date = creditInputState.creditDates[i]
            ..name = creditInputState.creditNames[i]
            ..price = creditInputState.creditPrices[i],
        );
      }

      if (creditInputState.creditDates[i] != '') {
        creditDateCount++;
      }

      if (creditInputState.creditNames[i] != '') {
        creditNameCount++;
      }

      if (creditInputState.creditPrices[i] > -1) {
        creditPriceCount++;
      }
    }

    if (list.isEmpty) {
      errFlg = true;
    }

    ////////////////////////// 同数チェック
    final countCheck = <int, String>{};
    countCheck[creditDateCount] = '';
    countCheck[creditNameCount] = '';
    countCheck[creditPriceCount] = '';

    // 同数の場合、要素数は1になる
    if (countCheck.length > 1) {
      errFlg = true;
    }
    ////////////////////////// 同数チェック

    if (errFlg == false) {
      list.forEach((element) {
        [
          [element.name, 15],
          [element.price, 10]
        ].forEach((element2) {
          if (checkInputValueLengthCheck(value: element2[0].toString(), length: element2[1] as int) == false) {
            errFlg = true;
          }
        });
      });
    }

    if (errFlg) {
      Future.delayed(
        Duration.zero,
        () => error_dialog(context: context, title: '登録できません。', content: '値を正しく入力してください。'),
      );

      await ref.read(appParamProvider.notifier).setInputButtonClicked(flag: false);

      return;
    }

    //---------------------------//
    final creditsCollection = CreditsRepository().getCollection(isar: widget.isar);
    final getCredits = await creditsCollection.filter().dateStartsWith(widget.date.yyyymm).findAll();
    if (getCredits.isNotEmpty) {
      await CreditsRepository().deleteCreditList(isar: widget.isar, creditList: getCredits);
    }
    //---------------------------//

    //---------------------------//
    deleteCreditList.forEach((element) {
      final param = <String, dynamic>{};
      param['date'] = element.date;
      param['price'] = element.price.toString();
      CreditDetailsRepository()
          .getCreditDetailListByDateAndPrice(isar: widget.isar, param: param)
          .then((value) async => widget.isar.writeTxn(() async => value?.forEach((element2) => CreditDetailsRepository().updateCreditDetail(
              isar: widget.isar,
              creditDetail: element2
                ..creditDate = ''
                ..creditPrice = ''))));
    });
    //---------------------------//

    await CreditsRepository()
        .inputCreditList(isar: widget.isar, creditList: list)
        .then((value) async => ref.read(creditProvider.notifier).clearInputValue().then((value) => Navigator.pop(context)));
  }

  ///
  Future<void> _clearOneBox({required int pos}) async {
    _creditNameTecs[pos].clear();
    _creditPriceTecs[pos].clear();

    await ref.read(creditProvider.notifier).clearOneBox(pos: pos);
  }

  ///
  void _addingDeleteCreditList({required String date, required int price}) => setState(() => deleteCreditList.add(Credit()
    ..date = date
    ..price = price));
}
