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

const darkPaper = Color(0xFF131A19);
const darkPaperStrong = Color(0xFF1F2B29);
const darkSurface = Color(0xFF1A2322);
const darkSurfaceMuted = Color(0xFF253230);
const darkInk = Color(0xFFE8E4DD);
const darkMuted = Color(0xFFBDB8AF);
const darkLine = Color(0xFF34413F);
const darkTeal = Color(0xFF5BBFB5);
const darkClay = Color(0xFFD98F7E);
const darkGold = Color(0xFFE8B94A);
const darkSage = Color(0xFF314336);

final brl = NumberFormat.simpleCurrency(locale: 'pt_BR');

ThemeData buildSeboTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: teal,
    brightness: brightness,
    primary: dark ? darkTeal : teal,
    secondary: dark ? darkClay : clay,
    tertiary: wine,
    surface: dark ? darkSurface : surface,
    onSurface: dark ? darkInk : ink,
    onSurfaceVariant: dark ? darkMuted : muted,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: dark ? darkPaper : paper,
    fontFamily: 'Roboto',
    brightness: brightness,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? darkSurface : surface,
      foregroundColor: dark ? darkInk : ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? darkSurface : surface,
      indicatorColor: dark ? darkSage : sage,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? (dark ? darkTeal : tealDark)
              : (dark ? darkMuted : muted),
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
        foregroundColor: dark ? darkTeal : teal,
        side: BorderSide(color: dark ? darkLine : line),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? darkSurfaceMuted : surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dark ? darkLine : line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dark ? darkLine : line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dark ? darkTeal : teal, width: 1.5),
      ),
      labelStyle: TextStyle(color: dark ? darkMuted : inkSoft),
      hintStyle: TextStyle(color: dark ? darkMuted : muted),
      prefixIconColor: dark ? darkMuted : inkSoft,
      suffixIconColor: dark ? darkTeal : teal,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: dark ? darkSurfaceMuted : surface,
      selectedColor: dark ? darkSage : sage,
      checkmarkColor: dark ? darkTeal : tealDark,
      side: BorderSide(color: dark ? darkLine : line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(
        color: dark ? darkInk : ink,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerColor: dark ? darkLine : line,
    textTheme: base.textTheme.apply(
      bodyColor: dark ? darkInk : ink,
      displayColor: dark ? darkInk : ink,
    ),
  );
}

extension SeboThemeColors on BuildContext {
  bool get isSeboDark => Theme.of(this).brightness == Brightness.dark;
  Color get seboPaper => isSeboDark ? darkPaper : paper;
  Color get seboPaperStrong => isSeboDark ? darkPaperStrong : paperStrong;
  Color get seboSurface => isSeboDark ? darkSurface : surface;
  Color get seboSurfaceMuted => isSeboDark ? darkSurfaceMuted : paperStrong;
  Color get seboInk => isSeboDark ? darkInk : ink;
  Color get seboInkSoft => isSeboDark ? darkMuted : inkSoft;
  Color get seboMuted => isSeboDark ? darkMuted : muted;
  Color get seboLine => isSeboDark ? darkLine : line;
  Color get seboTeal => isSeboDark ? darkTeal : teal;
  Color get seboTealDark => isSeboDark ? darkTeal : tealDark;
  Color get seboClay => isSeboDark ? darkClay : clay;
  Color get seboGold => isSeboDark ? darkGold : gold;
  Color get seboSage => isSeboDark ? darkSage : sage;
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
