import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../collections/config.dart';
import '../collections/credit.dart';
import '../collections/credit_detail.dart';
import '../collections/credit_item.dart';
import '../extensions/extensions.dart';
import '../repository/credit_details_repository.dart';
import '../repository/credit_items_repository.dart';
import '../repository/credits_repository.dart';
import '../state/app_params/app_params_notifier.dart';
import 'components/config_setting_alert.dart';
import 'components/credit_detail_input_alert.dart';
import 'components/credit_input_alert.dart';
import 'components/parts/back_ground_image.dart';
import 'components/parts/credit_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.isar});

  final Isar isar;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Config>? configList = [];

  Map<String, String> settingConfigMap = {};

  List<Credit>? creditList = [];

  List<CreditItem>? creditItemList = [];

  List<CreditDetail>? creditDetailList = [];

  final List<ScrollController> _scrollControllers = [];

  ///
  void _init() {
    _makeSettingConfigMap();

    _makeCreditList();

    _makeCreditItemList();

    _makeCreditDetailList();
  }

  ///
  @override
  Widget build(BuildContext context) {
    Future(_init);

    //==================================
    if (settingConfigMap['start_yearmonth'] != null && settingConfigMap['start_yearmonth'] != '') {
      final exYearmonth = settingConfigMap['start_yearmonth']!.split('-');
      if (exYearmonth.length > 1) {
        if (exYearmonth[0] != '' && exYearmonth[1] != '') {
          final firstDate = DateTime(exYearmonth[0].toInt(), exYearmonth[1].toInt());
          final diff = DateTime.now().difference(firstDate).inDays;
          final yearmonthList = <String>[];
          for (var i = 0; i <= diff; i++) {
            final yearmonth = firstDate.add(Duration(days: i)).yyyymm;
            if (!yearmonthList.contains(yearmonth)) {
              _scrollControllers.add(ScrollController());
            }
            yearmonthList.add(yearmonth);
          }
        }
      }
    }
    //==================================

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Credit List'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              final creditItemCountMap = <String, List<CreditDetail>>{};
              creditDetailList?.forEach((element) => creditItemCountMap[element.creditDetailItem] = []);
              creditDetailList?.forEach((element) => creditItemCountMap[element.creditDetailItem]?.add(element));

              CreditDialog(
                context: context,
                widget: ConfigSettingAlert(isar: widget.isar, creditItemCountMap: creditItemCountMap),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white.withOpacity(0.6), size: 20),
          )
        ],
      ),
      body: Stack(
        children: [
          const BackGroundImage(),
          Container(
            width: context.screenSize.width,
            height: context.screenSize.height,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
          ),
          Column(
            children: [
              if (settingConfigMap['start_yearmonth'] != null) ...[Expanded(child: _displayYearmonthList())],
            ],
          ),
        ],
      ),
      endDrawer: _dispEndDrawer(),
    );
  }

  ///
  Widget _dispEndDrawer() {
    final homeListSelectedYearmonth = ref.watch(appParamProvider.select((value) => value.homeListSelectedYearmonth));

    //===============================
    var sum = 0;
    final creList = <Credit>[];
    creditList?.forEach((element) {
      final exDate = element.date.split('-');
      if (homeListSelectedYearmonth == '${exDate[0]}-${exDate[1]}') {
        sum += element.price;
        creList.add(element);
      }
    });
    //===============================

    return Drawer(
      backgroundColor: Colors.blueGrey.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(homeListSelectedYearmonth),
                Text(sum.toString().toCurrency()),
              ],
            ),
            Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
            Expanded(child: _displayCreditDetailList()),
          ],
        ),
      ),
    );
  }

  ///
  Widget _displayCreditDetailList() {
    final list = <Widget>[];

    final homeListSelectedYearmonth = ref.watch(appParamProvider.select((value) => value.homeListSelectedYearmonth));

    if (creditDetailList != null) {
      creditDetailList!.where((element) => element.yearmonth == homeListSelectedYearmonth).toList()
        ..sort((a, b) => a.creditDetailDate.compareTo(b.creditDetailDate))
        ..forEach((element) {
          list.add(Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(element.creditDetailDate),
                    Text(element.creditDetailPrice.toString().toCurrency()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(element.creditDetailDescription),
                    Container(
                      width: context.screenSize.width / 4,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(element.creditDetailItem, style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ));
        });
    }

    return SingleChildScrollView(child: DefaultTextStyle(style: const TextStyle(fontSize: 12), child: Column(children: list)));
  }

  ///
  Future<void> _makeSettingConfigMap() async {
    final configsCollection = widget.isar.configs;

    final getConfigs = await configsCollection.where().findAll();

    setState(() {
      configList = getConfigs;

      getConfigs.forEach((element) => settingConfigMap[element.configKey] = element.configValue);
    });
  }

  ///
  Widget _displayYearmonthList() {
    final list = <Widget>[];

    if (settingConfigMap['start_yearmonth'] != null && settingConfigMap['start_yearmonth'] != '') {
      final exYearmonth = settingConfigMap['start_yearmonth']!.split('-');

      if (exYearmonth.length > 1) {
        if (exYearmonth[0] != '' && exYearmonth[1] != '') {
          final firstDate = DateTime(exYearmonth[0].toInt(), exYearmonth[1].toInt());

          final diff = DateTime.now().difference(firstDate).inDays;

          final yearmonthList = <String>[];

          for (var i = 0; i <= diff; i++) {
            final yearmonth = firstDate.add(Duration(days: i)).yyyymm;

            if (!yearmonthList.contains(yearmonth)) {
              //===============================
              var sum = 0;
              final creList = <Credit>[];
              creditList?.forEach((element) {
                final exDate = element.date.split('-');
                if (yearmonth == '${exDate[0]}-${exDate[1]}') {
                  sum += element.price;
                  creList.add(element);
                }
              });
              //===============================

              //===============================
              final itemBlankCreditDetailList = <CreditDetail>[];

              creditDetailList?.forEach((element) {
                if (yearmonth == element.yearmonth) {
                  //-----------------------------
                  if (element.creditDate == '' && element.creditPrice == '') {
                    itemBlankCreditDetailList.add(element);
                  }
                  //-----------------------------
                }
              });

              //===============================

              list.add(Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 70,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(yearmonth),
                                  const SizedBox(height: 5),
                                  Container(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        ref.read(appParamProvider.notifier).setInputButtonClicked(flag: false);

                                        CreditDialog(
                                          context: context,
                                          widget: CreditInputAlert(
                                            isar: widget.isar,
                                            date: DateTime.parse('$yearmonth-01 00:00:00'),
                                            creditList: creList,
                                            creditBlankCreditDetailList: itemBlankCreditDetailList,
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.4)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        ref.read(appParamProvider.notifier).setHomeListSelectedYearmonth(yearmonth: yearmonth);

                                        _scaffoldKey.currentState!.openEndDrawer();
                                      },
                                      child: Icon(Icons.list, color: Colors.greenAccent.withOpacity(0.4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        )),
                    Expanded(
                      child: Container(
                        height: context.screenSize.height / 10,
                        decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2))),
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollControllers[i],
                          child: ListView.separated(
                            controller: _scrollControllers[i],
                            itemBuilder: (context, index) {
                              //-----------------------------
                              final creDetList = <CreditDetail>[];
                              creditDetailList?.forEach((element) {
                                if (element.creditDate == creList[index].date && element.creditPrice == creList[index].price.toString()) {
                                  creDetList.add(element);
                                }
                              });
                              //-----------------------------

                              creDetList.sort((a, b) => a.creditDetailDate.compareTo(b.creditDetailDate));

                              ////////////////////////// 同数チェック
                              var inputedCreditDetailDateCount = 0;
                              var inputedCreditDetailItemCount = 0;
                              var inputedCreditDetailPriceCount = 0;
                              var inputedCreditDetailDescriptionCount = 0;
                              ////////////////////////// 同数チェック

                              var sum = 0;
                              creDetList.forEach((element) {
                                sum += element.creditDetailPrice;

                                ////////////////////////// 同数チェック
                                if (element.creditDetailDate != '') {
                                  inputedCreditDetailDateCount++;
                                }
                                if (element.creditDetailItem != '') {
                                  inputedCreditDetailItemCount++;
                                }
                                if (element.creditDetailPrice != 0) {
                                  inputedCreditDetailPriceCount++;
                                }
                                if (element.creditDetailDescription != '') {
                                  inputedCreditDetailDescriptionCount++;
                                }
                                ////////////////////////// 同数チェック
                              });

                              ////////////////////////// 同数チェック
                              final countCheck = <int, String>{};
                              countCheck[inputedCreditDetailDateCount] = '';
                              countCheck[inputedCreditDetailItemCount] = '';
                              countCheck[inputedCreditDetailPriceCount] = '';
                              countCheck[inputedCreditDetailDescriptionCount] = '';
                              final bool sameNumFlag;
                              if (countCheck.length > 1) {
                                sameNumFlag = false;
                              } else {
                                sameNumFlag = true;
                              }
                              ////////////////////////// 同数チェック

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 30, child: Text(DateTime.parse('${creList[index].date} 00:00:00').day.toString().padLeft(2, '0'))),
                                    Expanded(
                                      child: Text(creList[index].name,
                                          style: const TextStyle(color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ),
                                    Container(width: 60, alignment: Alignment.topRight, child: Text(creList[index].price.toString().toCurrency())),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(appParamProvider.notifier).setInputButtonClicked(flag: false);

                                        CreditDialog(
                                          context: context,
                                          widget: CreditDetailInputAlert(
                                            isar: widget.isar,
                                            creditDate: DateTime.parse('${creList[index].date} 00:00:00'),
                                            creditPrice: creList[index].price,
                                            creditItemList: creditItemList ?? [],
                                            creditDetailList: creDetList,
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.input, size: 20, color: Colors.greenAccent.withOpacity(0.4)),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: (creList[index].price == sum)
                                            ? sameNumFlag
                                                ? Colors.greenAccent.withOpacity(0.3)
                                                : Colors.yellowAccent.withOpacity(0.3)
                                            : Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => Container(),
                            itemCount: creList.length,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 70, alignment: Alignment.topRight, child: Text(sum.toString().toCurrency())),
                  ],
                ),
              ));
            }

            yearmonthList.add(yearmonth);
          }
        }
      }
    }

    return SingleChildScrollView(child: DefaultTextStyle(style: const TextStyle(fontSize: 12), child: Column(children: list)));
  }

  ///
  Future<void> _makeCreditList() async => CreditsRepository().getCreditList(isar: widget.isar).then((value) => setState(() => creditList = value));

  ///
  Future<void> _makeCreditItemList() async =>
      CreditItemsRepository().getCreditItemList(isar: widget.isar).then((value) => setState(() => creditItemList = value));

  ///
  Future<void> _makeCreditDetailList() async =>
      CreditDetailsRepository().getCreditDetailList(isar: widget.isar).then((value) => setState(() => creditDetailList = value));
}
