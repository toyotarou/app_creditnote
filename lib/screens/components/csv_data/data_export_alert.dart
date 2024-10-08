import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

import '../../../collections/config.dart';
import '../../../collections/credit.dart';
import '../../../collections/credit_detail.dart';
import '../../../collections/credit_item.dart';
import '../../../collections/subscription_item.dart';
import '../../../extensions/extensions.dart';
import '../../../repository/configs_repository.dart';
import '../../../repository/credit_details_repository.dart';
import '../../../repository/credit_items_repository.dart';
import '../../../repository/credits_repository.dart';
import '../../../repository/subscription_items_repository.dart';
import '../parts/error_dialog.dart';

part 'data_export_alert.freezed.dart';
part 'data_export_alert.g.dart';

class DataExportAlert extends ConsumerStatefulWidget {
  const DataExportAlert({super.key, required this.isar});

  final Isar isar;

  @override
  ConsumerState<DataExportAlert> createState() => _DataExportAlertState();
}

class _DataExportAlertState extends ConsumerState<DataExportAlert> {
  List<String> outputValuesList = <String>[];

  List<XFile> sendFileList = <XFile>[];
  List<String> sendFileNameList = <String>[];

  List<String> displayFileNameList = <String>[];

  ///
  @override
  void initState() {
    super.initState();

    outputValuesList.clear();

    sendFileNameList.clear();
    sendFileList.clear();

    displayFileNameList.clear();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final String csvName = ref.watch(
        dataExportProvider.select((DataExportState value) => value.csvName));

    final List<String> colorChangeFileNameList = <String>[];
    for (final String element in displayFileNameList) {
      colorChangeFileNameList.add(element.split('_')[0]);
    }

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
            children: <Widget>[
              Container(width: context.screenSize.width),
              const SizedBox(height: 20),
              const Text('データエクスポート'),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <String>[
                  'config',
                  'credit',
                  'creditDetail',
                  'creditItem',
                  'subscriptionItem',
                ].map(
                  (String e) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(dataExportProvider.notifier)
                                  .setCsvName(csvName: e);
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor:
                                  (colorChangeFileNameList.contains(e))
                                      ? Colors.greenAccent.withOpacity(0.3)
                                      : (csvName == e)
                                          ? Colors.yellowAccent.withOpacity(0.3)
                                          : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(e),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: csvOutput,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent.withOpacity(0.2)),
                      child: const Text('csv選択'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: csvSend,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent.withOpacity(0.2)),
                      child: const Text('送信'),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: displayFileNameList.map((String e) {
                  return Text(e);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> csvOutput() async {
    outputValuesList.clear();

    final String csvName = ref.watch(
        dataExportProvider.select((DataExportState value) => value.csvName));

    if (csvName == '') {
      getErrorDialog(title: '出力できません。', content: '出力するデータを正しく選択してください。');

      return;
    }

    outputValuesList.add('export_csv_from_credit_note');

    switch (csvName) {
      case 'config':
        await ConfigsRepository()
            .getConfigList(isar: widget.isar)
            .then((List<Config>? value) {
          value?.forEach((Config element) {
            outputValuesList.add(<Object>[
              element.id,
              element.configKey,
              element.configValue,
            ].join(','));
          });
        });
      case 'credit':
        await CreditsRepository()
            .getCreditList(isar: widget.isar)
            .then((List<Credit>? value) {
          value?.forEach((Credit element) {
            outputValuesList.add(<Object>[
              element.id,
              element.date,
              element.name,
              element.price
            ].join(','));
          });
        });
      case 'creditDetail':
        await CreditDetailsRepository()
            .getCreditDetailList(isar: widget.isar)
            .then((List<CreditDetail>? value) {
          value?.forEach((CreditDetail element) {
            outputValuesList.add(<Object>[
              element.id,
              element.yearmonth,
              element.creditDate,
              element.creditPrice,
              element.creditDetailDate,
              element.creditDetailItem,
              element.creditDetailDescription,
              element.creditDetailPrice,
            ].join(','));
          });
        });
      case 'creditItem':
        await CreditItemsRepository()
            .getCreditItemList(isar: widget.isar)
            .then((List<CreditItem>? value) {
          value?.forEach((CreditItem element) {
            outputValuesList.add(<Object>[
              element.id,
              element.name,
              element.order,
              element.color,
            ].join(','));
          });
        });
      case 'subscriptionItem':
        await SubscriptionItemsRepository()
            .getSubscriptionItemList(isar: widget.isar)
            .then((List<SubscriptionItem>? value) {
          value?.forEach((SubscriptionItem element) {
            outputValuesList.add(<Object>[element.id, element.name].join(','));
          });
        });
    }

    final DateTime now = DateTime.now();
    final DateFormat timeFormat = DateFormat('HHmmss');
    final String currentTime = timeFormat.format(now);

    final String year = now.year.toString();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');

    final String dateStr = '${csvName}_$year$month$day$currentTime';
    final String sendFileName = '$dateStr.csv';

    final String contents = outputValuesList.join('\n');

    final List<int> byteList = utf8.encode(contents);

    final Uint8List encoded = Uint8List.fromList(byteList);

    sendFileNameList.add(sendFileName);
    sendFileList.add(XFile.fromData(encoded, mimeType: 'text/plain'));

    setState(() {
      displayFileNameList = sendFileNameList;
    });
  }

  ///
  Future<void> csvSend() async {
    if (sendFileList.isEmpty || sendFileNameList.isEmpty) {
      getErrorDialog(title: '送信できません。', content: '送信するデータを正しく選択してください。');

      return;
    }

    final RenderBox? box = context.findRenderObject() as RenderBox?;

    await Share.shareXFiles(
      sendFileList,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      fileNameOverrides: sendFileNameList,
    );

    if (mounted) {
      outputValuesList.clear();

      sendFileNameList.clear();
      sendFileList.clear();

      Navigator.pop(context);
    }
  }

  ///
  void getErrorDialog({required String title, required String content}) {
    // ignore: always_specify_types
    Future.delayed(
      Duration.zero,
      () {
        if (mounted) {
          return error_dialog(context: context, title: title, content: content);
        }
      },
    );
  }
}

@freezed
class DataExportState with _$DataExportState {
  const factory DataExportState({
    @Default('') String csvName,
  }) = _DummyDownloadState;
}

@riverpod
class DataExport extends _$DataExport {
  ///
  @override
  DataExportState build() {
    return const DataExportState();
  }

  ///
  void setCsvName({required String csvName}) {
    state = state.copyWith(csvName: csvName);
  }
}
