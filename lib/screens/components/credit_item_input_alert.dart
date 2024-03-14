import 'dart:ui';

import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../collections/credit_item.dart';
import '../../extensions/extensions.dart';
import 'parts/credit_item_card.dart';

class CreditItemInputAlert extends ConsumerStatefulWidget {
  const CreditItemInputAlert({super.key, required this.isar, required this.creditItemList});

  final Isar isar;

  final List<CreditItem> creditItemList;

  @override
  ConsumerState<CreditItemInputAlert> createState() => _CreditItemInputAlertState();
}

class _CreditItemInputAlertState extends ConsumerState<CreditItemInputAlert> {
  final TextEditingController _creditItemEditingController = TextEditingController();

  List<DragAndDropItem> creditItemDDItemList = [];
  List<DragAndDropList> ddList = [];

  List<int> orderedIdList = [];

  Color mycolor = Colors.white;

  Map<int, String> creditItemColorMap = {};

  Map<int, String> creditItemDefaultTimeMap = {};

  Map<int, String> creditItemNameMap = {};

  ///
  @override
  void initState() {
    super.initState();

    widget.creditItemList.forEach((element) {
      final colorCode = (element.color != '') ? element.color : '0xffffffff';

      creditItemDDItemList.add(
        DragAndDropItem(
          child: CreditItemCard(
            key: Key(element.id.toString()),
            name: element.name,
            deleteButtonPress: () => _showDeleteDialog(id: element.id),
            colorPickerButtonPress: () => _showColorPickerDialog(id: element.id),
            colorCode: colorCode,
            isar: widget.isar,
          ),
        ),
      );

      creditItemColorMap[element.id] = element.color;

      creditItemNameMap[element.id] = element.name;
    });

    ddList.add(DragAndDropList(children: creditItemDDItemList));
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: DefaultTextStyle(
            style: GoogleFonts.kiwiMaru(fontSize: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(width: context.screenSize.width),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('分類アイテム管理'), Container()],
                ),
                Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
                _displayInputParts(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          GestureDetector(
                            onTap: _inputCreditItem,
                            child: Text(
                              '分類アイテムを追加する',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          GestureDetector(
                            onTap: _settingReorderIds,
                            child: Text(
                              '並び順を保存する',
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: DragAndDropLists(
                      children: ddList,
                      onItemReorder: _itemReorder,
                      onListReorder: _listReorder,

                      ///
                      itemDecorationWhileDragging: const BoxDecoration(
                        color: Colors.black,
                        boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)],
                      ),

                      ///
                      lastListTargetSize: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayInputParts() {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(blurRadius: 24, spreadRadius: 16, color: Colors.black.withOpacity(0.2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: context.screenSize.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: TextField(
              controller: _creditItemEditingController,
              decoration: const InputDecoration(labelText: '分類アイテム'),
              style: const TextStyle(fontSize: 13, color: Colors.white),
              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _inputCreditItem() async {
    // if (_spendItemEditingController.text == '') {
    //   Future.delayed(
    //     Duration.zero,
    //     () => error_dialog(context: context, title: '登録できません。', content: '値を正しく入力してください。'),
    //   );
    //
    //   return;
    // }
    //
    // final spendItem = SpendItem()
    //   ..spendItemName = _spendItemEditingController.text
    //   ..order = widget.spendItemList.length + 1
    //   ..defaultTime = '08:00'
    //   ..color = '0xffffffff';
    //
    // await SpendItemsRepository().inputSpendItem(isar: widget.isar, spendItem: spendItem).then((value) {
    //   _spendItemEditingController.clear();
    //   Navigator.pop(context);
    // });
  }

  ///
  void _itemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      final movedItem = ddList[oldListIndex].children.removeAt(oldItemIndex);

      ddList[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  ///
  void _listReorder(int oldListIndex, int newListIndex) {}

  ///
  void _showDeleteDialog({required int id}) {
    final Widget cancelButton = TextButton(onPressed: () => Navigator.pop(context), child: const Text('いいえ'));

    final Widget continueButton = TextButton(
        onPressed: () {
          _deleteCreditItem(id: id);

          Navigator.pop(context);
        },
        child: const Text('はい'));

    final alert = AlertDialog(
      backgroundColor: Colors.blueGrey.withOpacity(0.3),
      content: const Text('このデータを消去しますか？'),
      actions: [cancelButton, continueButton],
    );

    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  // ///
  // Future<void> _deleteSpendItem({required int id}) async {
  //   await SpendItemsRepository().getSpendItem(isar: widget.isar, id: id).then((value) {
  //     final param = <String, dynamic>{};
  //     param['item'] = value!.spendItemName;
  //
  //     SpendTimePlacesRepository().getSpendTypeSpendTimePlaceList(isar: widget.isar, param: param).then((value2) {
  //       final spendTimePriceList = <SpendTimePlace>[];
  //       value2!.forEach((element) => spendTimePriceList.add(element..spendType = ''));
  //
  //       SpendTimePlacesRepository()
  //           .updateSpendTimePriceList(isar: widget.isar, spendTimePriceList: spendTimePriceList)
  //           .then((value3) => SpendItemsRepository()
  //               .deleteSpendItem(isar: widget.isar, id: id)
  //               .then((value4) => Navigator.pop(context)));
  //     });
  //   });
  // }

  ///
  Future<void> _deleteCreditItem({required int id}) async {
    // //-----------------------------------
    // final spendTimePlacesCollection = widget.isar.spendTimePlaces;
    //
    // final getSpendTimePlaces =
    //     await spendTimePlacesCollection.filter().spendTypeEqualTo(spendItemNameMap[id]!).findAll();
    //
    // await widget.isar.writeTxn(() async =>
    //     getSpendTimePlaces.forEach((element) async => widget.isar.spendTimePlaces.put(element..spendType = '')));
    // //-----------------------------------
    //
    // final spendItemsCollection = widget.isar.spendItems; //TODO
    // await widget.isar.writeTxn(() async => spendItemsCollection.delete(id));
    //
    // if (mounted) {
    //   Navigator.pop(context);
    // }
  }

  // ///
  // Future<void> _settingReorderIds() async {
  //   orderedIdList = [];
  //
  //   for (final value in ddList) {
  //     for (final child in value.children) {
  //       orderedIdList.add(child.child.key
  //           .toString()
  //           .replaceAll('[', '')
  //           .replaceAll('<', '')
  //           .replaceAll("'", '')
  //           .replaceAll('>', '')
  //           .replaceAll(']', '')
  //           .toInt());
  //     }
  //   }
  //
  //   await widget.isar.writeTxn(() async {
  //     for (var i = 0; i < orderedIdList.length; i++) {
  //       await SpendItemsRepository().getSpendItem(isar: widget.isar, id: orderedIdList[i]).then((value) {
  //         value!.order = i;
  //
  //         SpendItemsRepository()
  //             .updateSpendItem(isar: widget.isar, spendItem: value)
  //             .then((value) => Navigator.pop(context));
  //       });
  //     }
  //   });
  // }

  ///
  Future<void> _settingReorderIds() async {
    orderedIdList = [];

    for (final value in ddList) {
      for (final child in value.children) {
        orderedIdList.add(child.child.key
            .toString()
            .replaceAll('[', '')
            .replaceAll('<', '')
            .replaceAll("'", '')
            .replaceAll('>', '')
            .replaceAll(']', '')
            .toInt());
      }
    }

    // final spendItemsCollection = widget.isar.spendItems;
    //
    // await widget.isar.writeTxn(() async {
    //   for (var i = 0; i < orderedIdList.length; i++) {
    //     final getSpendItem = await spendItemsCollection.filter().idEqualTo(orderedIdList[i]).findFirst();
    //     if (getSpendItem != null) {
    //       getSpendItem
    //         ..spendItemName = spendItemNameMap[orderedIdList[i]].toString()
    //         ..order = i;
    //
    //       await widget.isar.spendItems.put(getSpendItem);
    //     }
    //   }
    // });
    //
    // if (mounted) {
    //   Navigator.pop(context);
    // }
  }

  ///
  void _showColorPickerDialog({required int id}) {
    if (creditItemColorMap[id] != null && creditItemColorMap[id] != '') {
      mycolor = Color(creditItemColorMap[id]!.toInt());
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey.withOpacity(0.3),
          title: const Text('Pick a color!', style: TextStyle(fontSize: 12)),
          content: BlockPicker(
            availableColors: const [
              Colors.white,
              Colors.pinkAccent,
              Colors.redAccent,
              Colors.deepOrangeAccent,
              Colors.orangeAccent,
              Colors.amberAccent,
              Colors.yellowAccent,
              Colors.lightGreenAccent,
              Colors.greenAccent,
              Colors.tealAccent,
              Colors.cyanAccent,
              Colors.lightBlueAccent,
              Colors.purpleAccent,
              Color(0xFFFBB6CE),
              Colors.grey,
            ],
            pickerColor: mycolor,
            onColorChanged: (Color color) async {
              mycolor = color;

              final exColor = color.toString().split(' ');
              var colorCode = '';
              if (exColor.length == 3) {
                colorCode = exColor[2].replaceAll('Color(', '').replaceAll(')', '');
              } else {
                colorCode = exColor[0].replaceAll('Color(', '').replaceAll(')', '');
              }

              await _updateColorCode(id: id, color: colorCode).then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
              });
            },
          ),
        );
      },
    );
  }

  // ///
  // Future<void> _showDefaultTimeDialog({required int id}) async {
  //   final initialHour = (creditItemDefaultTimeMap[id] != null && creditItemDefaultTimeMap[id] != '')
  //       ? creditItemDefaultTimeMap[id]!.split(':')[0].toInt()
  //       : 8;
  //
  //   final selectedTime = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay(hour: initialHour, minute: 0),
  //     builder: (context, child) {
  //       return MediaQuery(
  //         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
  //         child: child ?? Container(),
  //       );
  //     },
  //   );
  //
  //   if (selectedTime != null) {
  //     final time = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
  //
  //     await _updateDefaultTime(id: id, time: time).then((value) {
  //       Navigator.pop(context);
  //       Navigator.pop(context);
  //     });
  //   }
  // }

  ///
  Future<void> _updateColorCode({required int id, required String color}) async {
    // await widget.isar.writeTxn(() async {
    //   await SpendItemsRepository().getSpendItem(isar: widget.isar, id: id).then((value) async {
    //     value!.color = color;
    //
    //     await SpendItemsRepository().updateSpendItem(isar: widget.isar, spendItem: value);
    //   });
    // });
  }

// ///
// Future<void> _updateDefaultTime({required int id, required String time}) async {
//   // await widget.isar.writeTxn(() async {
//   //   await SpendItemsRepository().getSpendItem(isar: widget.isar, id: id).then((value) async {
//   //     value!.defaultTime = time;
//   //
//   //     await SpendItemsRepository().updateSpendItem(isar: widget.isar, spendItem: value);
//   //   });
//   // });
// }
}
