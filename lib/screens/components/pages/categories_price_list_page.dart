import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';

import '../../../collections/credit_detail.dart';
import '../../../collections/credit_item.dart';
import '../../../extensions/extensions.dart';

class CategoriesPriceListPage extends StatefulWidget {
  const CategoriesPriceListPage(
      {super.key,
      required this.isar,
      required this.date,
      required this.creditItemList,
      required this.creditDetailList});

  final Isar isar;
  final DateTime date;
  final List<CreditItem>? creditItemList;
  final List<CreditDetail>? creditDetailList;

  @override
  State<CategoriesPriceListPage> createState() =>
      _CategoriesPriceListPageState();
}

class _CategoriesPriceListPageState extends State<CategoriesPriceListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Container(width: context.screenSize.width),
              Expanded(child: _displayCategoriesPriceList()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayCategoriesPriceList() {
    final List<Widget> list = <Widget>[];

    final Map<String, List<CreditDetail>> categoriesPriceMap =
        <String, List<CreditDetail>>{};

    final Map<String, String> creditItemColorMap = <String, String>{};
    widget.creditItemList?.forEach((CreditItem element) {
      creditItemColorMap[element.name] = element.color;

      categoriesPriceMap[element.name] = <CreditDetail>[];
    });

    if (widget.creditDetailList != null) {
      int total = 0;

      /// 複数条件でソートする
      widget.creditDetailList!
          .where(
              (CreditDetail element) => element.yearmonth == widget.date.yyyymm)
          .toList()
        ..sort((CreditDetail a, CreditDetail b) {
          final int result = a.creditDetailDate.compareTo(b.creditDetailDate);
          if (result != 0) {
            return result;
          }
          return -1 * a.creditDetailPrice.compareTo(b.creditDetailPrice);
        })
        ..forEach((CreditDetail element) {
          categoriesPriceMap[element.creditDetailItem]?.add(element);
        });

      final List<Widget> list2 = <Widget>[];
      widget.creditItemList?.forEach((CreditItem element) {
        if (categoriesPriceMap[element.name] != null) {
          final String? lineColor = (creditItemColorMap[element.name] != null &&
                  creditItemColorMap[element.name] != '')
              ? creditItemColorMap[element.name]
              : '0xffffffff';

          int sum = 0;
          categoriesPriceMap[element.name]?.forEach(
              (CreditDetail element2) => sum += element2.creditDetailPrice);

          total += sum;

          if (sum > 0) {
            list2.add(Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: Colors.white.withOpacity(0.3)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: context.screenSize.width / 6,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color(lineColor!.toInt()).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: FittedBox(
                        child: Text(element.name,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis)),
                  ),
                  Text(sum.toString().toCurrency()),
                ],
              ),
            ));
          }
        }
      });

      list
        ..add(Column(children: list2))
        ..add(Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(),
              Text(
                total.toString().toCurrency(),
                style: const TextStyle(color: Colors.yellowAccent),
              ),
            ],
          ),
        ));
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => list[index],
            childCount: list.length,
          ),
        ),
      ],
    );
  }
}
