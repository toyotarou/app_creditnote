import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../collections/credit_detail.dart';
import '../../collections/credit_item.dart';
import '../../collections/subscription_item.dart';
import '../../extensions/extensions.dart';
import '../../repository/subscription_items_repository.dart';
import 'credit_detail_edit_alert.dart';
import 'parts/credit_dialog.dart';

class SameItemListAlert extends ConsumerStatefulWidget {
  const SameItemListAlert({
    super.key,
    required this.isar,
    required this.creditDetail,
    required this.creditDetailList,
    required this.creditItemList,
    required this.subscriptionItemList,
  });

  final Isar isar;
  final CreditDetail creditDetail;
  final List<CreditDetail>? creditDetailList;
  final List<CreditItem> creditItemList;
  final List<SubscriptionItem> subscriptionItemList;

  @override
  ConsumerState<SameItemListAlert> createState() => _SameItemListAlertState();
}

class _SameItemListAlertState extends ConsumerState<SameItemListAlert> {
  ///
  @override
  Widget build(BuildContext context) {
    final List<String> subscriptionItems = <String>[];
    for (final SubscriptionItem element in widget.subscriptionItemList) {
      subscriptionItems.add(element.name);
    }

    final Color subscriptionColor = (subscriptionItems
            .contains(widget.creditDetail.creditDetailDescription))
        ? Colors.yellowAccent
        : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.creditDetail.creditDetailDescription),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(),
                      Row(
                        children: <Widget>[
                          Text('月極登録',
                              style: TextStyle(
                                  color: subscriptionColor.withOpacity(0.6))),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: subscriptionItemInputDeleteToggle,
                            child: Icon(Icons.settings_applications_sharp,
                                color: subscriptionColor.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Expanded(child: _displaySameItemCreditDetailList()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget _displaySameItemCreditDetailList() {
    final List<Widget> list = <Widget>[];

    final Map<String, String> spendItemColorMap = <String, String>{};
    for (final CreditItem element in widget.creditItemList) {
      spendItemColorMap[element.name] = element.color;
    }

    widget.creditDetailList!
        .where((CreditDetail element) =>
            element.creditDetailDescription ==
            widget.creditDetail.creditDetailDescription)
        .toList()
      ..sort((CreditDetail a, CreditDetail b) {
        final int result = a.creditDetailDate.compareTo(b.creditDetailDate);
        if (result != 0) {
          return result;
        }
        return -1 * a.creditDetailPrice.compareTo(b.creditDetailPrice);
      })
      ..forEach((CreditDetail element) {
        final String? lineColor =
            (spendItemColorMap[element.creditDetailItem] != null &&
                    spendItemColorMap[element.creditDetailItem] != '')
                ? spendItemColorMap[element.creditDetailItem]
                : '0xffffffff';

        list.add(Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(element.creditDetailDate)),
              Expanded(
                  child: Container(
                      alignment: Alignment.topRight,
                      child: Text(
                          element.creditDetailPrice.toString().toCurrency()))),
              const SizedBox(width: 20),
              Container(
                width: context.screenSize.width / 6,
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(vertical: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Color(lineColor!.toInt()).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: FittedBox(
                    child: Text(element.creditDetailItem,
                        style: const TextStyle(fontSize: 10))),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  CreditDialog(
                    context: context,
                    widget: CreditDetailEditAlert(
                        isar: widget.isar,
                        creditDetail: element,
                        creditItemList: widget.creditItemList,
                        from: 'SameItemListAlert'),
                  );
                },
                child: Icon(Icons.edit,
                    color: Colors.greenAccent.withOpacity(0.4), size: 16),
              ),
            ],
          ),
        ));
      });

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

  ///
  Future<void> subscriptionItemInputDeleteToggle() async {
    await SubscriptionItemsRepository()
        .getSubscriptionItemByName(
            isar: widget.isar,
            name: widget.creditDetail.creditDetailDescription)
        .then((SubscriptionItem? value) {
      if (value == null) {
        final SubscriptionItem subscriptionItem = SubscriptionItem()
          ..name = widget.creditDetail.creditDetailDescription;
        SubscriptionItemsRepository().inputSubscriptionItem(
            isar: widget.isar, subscriptionItem: subscriptionItem);
      } else {
        SubscriptionItemsRepository()
            .deleteSubscriptionItem(isar: widget.isar, id: value.id);
      }
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
