import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../collections/config.dart';
import '../collections/credit.dart';
import '../extensions/extensions.dart';
import '../repository/credit_repository.dart';
import 'components/config_setting_alert.dart';
import 'components/credit_input_alert.dart';
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

  Map<String, List<Credit>> creditMap = {};

  ///
  void _init() {
    makeSettingConfigMap();

    makeCreditList();
  }

  ///
  @override
  Widget build(BuildContext context) {
    Future(_init);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Credit List'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              CreditDialog(context: context, widget: ConfigSettingAlert(isar: widget.isar));
            },
            icon: Icon(Icons.settings, color: Colors.white.withOpacity(0.6), size: 20),
          )
        ],
      ),
      body: Column(
        children: [
          if (settingConfigMap['start_yearmonth'] != null) ...[Expanded(child: _displayYearmonthList())],
        ],
      ),
      drawer: _dispDrawer(),
      endDrawer: _dispEndDrawer(),
    );
  }

  ///
  Widget _dispDrawer() {
    return Drawer(
      backgroundColor: Colors.blueGrey.withOpacity(0.2),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  ///
  Widget _dispEndDrawer() {
    return Drawer(
      backgroundColor: Colors.blueGrey.withOpacity(0.2),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

  ///
  Future<void> makeSettingConfigMap() async {
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
              var sum = 0;
              if (creditMap[yearmonth] != null) {
                creditMap[yearmonth]!.forEach((element) {
                  sum += element.price;
                });
              }

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
                                      onTap: () => CreditDialog(
                                        context: context,
                                        widget: CreditInputAlert(
                                          isar: widget.isar,
                                          date: DateTime.parse('$yearmonth-01 00:00:00'),
                                          creditList: creditMap[yearmonth],
                                        ),
                                      ),
                                      child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.4)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
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
                        child: SingleChildScrollView(
                          child: (creditMap[yearmonth] != null)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: creditMap[yearmonth]!.map((e) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Text(
                                              DateTime.parse('${e.date} 00:00:00').day.toString().padLeft(2, '0'),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              e.name,
                                              style: const TextStyle(color: Colors.grey),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            width: 60,
                                            alignment: Alignment.topRight,
                                            child: Text(e.price.toString().toCurrency()),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Icons.input,
                                            size: 20,
                                            color: Colors.greenAccent.withOpacity(0.4),
                                          ),
                                          const SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              _scaffoldKey.currentState!.openDrawer();
                                            },
                                            child: Icon(Icons.list, color: Colors.greenAccent.withOpacity(0.4)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Container(),
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

    return SingleChildScrollView(
        child: DefaultTextStyle(style: const TextStyle(fontSize: 12), child: Column(children: list)));
  }

  ///
  Future<void> makeCreditList() async {
    await CreditRepository().getCreditList(isar: widget.isar).then((value) {
      creditList = value;

      if (value!.isNotEmpty) {
        value
          ..forEach((element) => creditMap[DateTime.parse('${element.date} 00:00:00').yyyymm] = [])
          ..forEach((element) => creditMap[DateTime.parse('${element.date} 00:00:00').yyyymm]?.add(element));
      }
    });
  }
}
