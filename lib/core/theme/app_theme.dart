import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
enum BottomTab { home, noticias, anuncios }

class AppColors {
  // Colores principales
  static const primary = Color(0xFFE63330);
  static const secondary = Color(0xFF5AADE1);
  static const background = Color(0xFFEFEFEF);
  static const borderTetxForm = Color(0xFFCACACA);
  static const basic = Color(0xFF0D1D35);
  static const basicBack = Color(0xFF066BAF);
  static const lightModeBlue = Color(0xFF005EA3);

  static const forexColor = Color(0xFF066BAF);
  static const selectedColor = Color(0xFFE53935);

  // Variaciones de colores principales para estados
  static const primaryLight = Color(0xFFFF5652);
  static const primaryDark = Color(0xFFCC1D1A);
  static const secondaryLight = Color(0xFF7BC1E9);
  static const secondaryDark = Color(0xFF4189B0);

  // Colores de estado
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFD32F2F);
  static const info = secondary;

  // Colores de texto
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textLight = Color(0xFFFFFFFF);
}

class AppTextStyles {
  // Montserrat - Tipografía Principal
  static TextStyle get displayLarge => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineLarge => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Títulos (usando Montserrat temporalmente)
  static TextStyle get titleLarge => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  // Estilos de texto para el cuerpo
  static TextStyle get bodyLarge => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: Colors.white,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
      ),
      appBarTheme: AppBarTheme(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        backgroundColor: const Color(0xFF0D1D35),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          // Color de la bolita
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // Activo
          }
          return Colors.black12; // Inactivo
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          // Color de la barra
          if (states.contains(WidgetState.selected)) {
            return Colors.green; // Activo
          }
          return Colors.grey; // Inactivo
        }),
      ),
      iconTheme: const IconThemeData(
          color: Colors.black
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: const Color(0xFFEEEEEE),
        collapsedBackgroundColor: Colors.transparent,

        iconColor: Colors.white,
        collapsedIconColor: Colors.white54,


        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightModeBlue,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderTetxForm),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          const Color(0xFFFEF4F4),
        ),
        headingTextStyle: AppTextStyles.titleSmall,
        dataRowColor: WidgetStateProperty.all(Colors.white),
        dataTextStyle: AppTextStyles.bodyMedium,
        dividerThickness: 1,
      ),
      /// CardThemeData ---> CardTheme ---> se cambio a CardTheme por que no se  reconoce el CardThemeData
      cardTheme:  CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  /// Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFF0F172A),
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1425),
      appBarTheme: AppBarTheme(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        backgroundColor: const Color(0xFF0D1D35),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          textStyle: WidgetStateProperty.all(
            AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          const Color(0xFF0F4479), // header dark
        ),
        headingTextStyle: AppTextStyles.titleSmall.copyWith(
          color: Colors.white,
        ),
        dataRowColor: WidgetStateProperty.all(
          const Color(0xFF0F2D4A),
        ),
        dataTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white70,
        ),
        dividerThickness: 0.8,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF092949),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary.withOpacity(0.25),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D1D35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF2E4A66), // gris dark
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary, // rojo
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),

        labelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: const Color(0xFF0D1D35),
        collapsedBackgroundColor: Colors.transparent,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white54,
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),
      switchTheme: const SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(Color(0xFF005EA3)),
        trackColor: WidgetStatePropertyAll(Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          textStyle: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }


}

extension AppThemeColors on ThemeData {
  ///CARD ALERTAS
  Color get linkColor => brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF036BAF);
  Color get borderColor => brightness == Brightness.dark
      ? const Color(0xFF2E4A66)
      : Colors.grey.shade400;
  Color get chipsColors => brightness == Brightness.dark
      ? const Color(0xFF101010)
      : const Color(0xFF101010);
  Color get previewColors => brightness == Brightness.dark
      ? const Color(0xFF0D3B6A)
      : Colors.white;
  Color get borderPreviewColors => brightness == Brightness.dark
      ? const Color(0xFF2E4A66)
      : Colors.white;
  Color get borderCardPreviewColors => brightness == Brightness.dark
      ? const Color(0xFF2E4A66)
      : Colors.transparent;
  Color get textCardPreviewColors => brightness == Brightness.dark
      ? Colors.white
      :const Color(0xFF101010);
}
