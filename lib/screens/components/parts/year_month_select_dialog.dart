import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../extensions/extensions.dart';
import '../../../state/data_download/data_download_notifier.dart';

class YearMonthSelectDialog extends ConsumerStatefulWidget {
  const YearMonthSelectDialog({super.key, required this.pos, required this.selectedYearmonthList});

  final String pos;

  final List<String> selectedYearmonthList;

  ///
  @override
  ConsumerState<YearMonthSelectDialog> createState() => _YearMonthSelectDialogState();
}

class _YearMonthSelectDialogState extends ConsumerState<YearMonthSelectDialog> {
  @override
  Widget build(BuildContext context) {
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
                children: [Text('${(widget.pos == 'start') ? '開始' : '終了'}年月を選択'), Container()],
              ),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Expanded(child: _displayYearMonthList()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayYearMonthList() {
    final list = <Widget>[];

    widget.selectedYearmonthList.forEach((element) {
      list.add(
        GestureDetector(
          onTap: () {
            switch (widget.pos) {
              case 'start':
                ref.read(dataDownloadProvider.notifier).setStartYearMonth(yearmonth: element);
                break;
              case 'end':
                ref.read(dataDownloadProvider.notifier).setEndYearMonth(yearmonth: element);
                break;
            }

            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: Text(element),
          ),
        ),
      );
    });

    return SingleChildScrollView(child: Column(children: list));
  }
}
