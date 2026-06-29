import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const paper = Color(0xFFFBF7ED);
const paperStrong = Color(0xFFF2EAD8);
const surface = Color(0xFFFFFDF8);
const ink = Color(0xFF24322F);
const inkSoft = Color(0xFF40514D);
const muted = Color(0xFF756F63);
const line = Color(0xFFE4DCCB);
const teal = Color(0xFF286C67);
const tealDark = Color(0xFF164C4A);
const clay = Color(0xFFB65F45);
const wine = Color(0xFF793F56);
const gold = Color(0xFFD4A33D);
const sage = Color(0xFFDFE8D5);
const sky = Color(0xFFD8E6EA);

final brl = NumberFormat.simpleCurrency(locale: 'pt_BR');

ThemeData buildSeboTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: teal,
    brightness: Brightness.light,
    primary: teal,
    secondary: clay,
    tertiary: wine,
    surface: surface,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: paper,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: sage,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected) ? tealDark : muted,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: teal,
        side: const BorderSide(color: line),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: teal, width: 1.5),
      ),
      labelStyle: const TextStyle(color: inkSoft),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: surface,
      selectedColor: sage,
      checkmarkColor: tealDark,
      side: const BorderSide(color: line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
    dividerColor: line,
    textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
  );
}

String money(double? value) {
  if (value == null) return 'Preco indisponivel';
  return brl.format(value);
}

String shortDate(DateTime? value) {
  if (value == null) return 'A confirmar';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String dateTimeLabel(DateTime? value) {
  if (value == null) return 'Data indisponivel';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} as $hour:$minute';
}
