import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/config.dart';
import 'collections/credit.dart';
import 'collections/credit_detail.dart';
import 'collections/credit_item.dart';
import 'collections/subscription_item.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Directory dir = await getApplicationSupportDirectory();

  // ignore: always_specify_types
  final Isar isar = await Isar.open([
    ConfigSchema,
    CreditSchema,
    CreditItemSchema,
    CreditDetailSchema,
    SubscriptionItemSchema,
  ], directory: dir.path);

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(ProviderScope(child: MyApp(isar: isar))));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.isar});

  final Isar isar;

  ///
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      // ignore: always_specify_types, prefer_const_literals_to_create_immutables
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('ja'),
      ],
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.kiwiMaru(
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
        ),
        scrollbarTheme: const ScrollbarThemeData().copyWith(
            thumbColor:
                MaterialStateProperty.all(Colors.greenAccent.withOpacity(0.4))),
        useMaterial3: false,
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark),
        fontFamily: 'KiwiMaru',
        highlightColor: Colors.grey,
      ),
      themeMode: ThemeMode.dark,
      title: 'credit note',
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
          onTap: () => primaryFocus?.unfocus(), child: HomeScreen(isar: isar)),
    );
  }
}
