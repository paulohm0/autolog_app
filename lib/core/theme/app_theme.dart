import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // impedir instanciação
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      extensions: const [AppColorsExtension.light],
    );
  }

  static ThemeData get darkTheme {
    const colors = AppColorsExtension.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: colors.background,
      fontFamily: AppTextStyles.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.primary,
        contentTextStyle: TextStyle(
          color: colors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      extensions: const [AppColorsExtension.dark],
    );
  }
}

/// Cores que mudam entre os temas claro/escuro. Acesse via `context.colors`
/// em vez de `AppColors` direto — [AppColors] guarda só os valores fixos do
/// tema claro (usados como default e nas constantes de [AppColorsExtension.light]).
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textOnPrimary;
  final Color success;
  final Color warning;
  final Color error;
  final Color border;
  final Color borderFocused;
  final Color shadow;

  const AppColorsExtension({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textOnPrimary,
    required this.success,
    required this.warning,
    required this.error,
    required this.border,
    required this.borderFocused,
    required this.shadow,
  });

  static const light = AppColorsExtension(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryLight: AppColors.primaryLight,
    background: AppColors.background,
    surface: AppColors.surface,
    surfaceVariant: AppColors.surfaceVariant,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textHint: AppColors.textHint,
    textOnPrimary: AppColors.textOnPrimary,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    border: AppColors.border,
    borderFocused: AppColors.borderFocused,
    shadow: Color(0x26000000),
  );

  static const dark = AppColorsExtension(
    primary: Color(0xFF5B7FFF),
    primaryDark: Color(0xFF3D5FE0),
    primaryLight: Color(0xFF1E2A4A),
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceVariant: Color(0xFF21262D),
    textPrimary: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF8B949E),
    textHint: Color(0xFF6E7681),
    textOnPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF3FB950),
    warning: Color(0xFFD29922),
    error: Color(0xFFF85149),
    border: Color(0xFF30363D),
    borderFocused: Color(0xFF5B7FFF),
    shadow: Color(0x26000000),
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? textOnPrimary,
    Color? success,
    Color? warning,
    Color? error,
    Color? border,
    Color? borderFocused,
    Color? shadow,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      border: border ?? this.border,
      borderFocused: borderFocused ?? this.borderFocused,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocused: Color.lerp(borderFocused, other.borderFocused, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Acesso rápido à paleta do tema atual: `context.colors.primary` em vez de
/// `AppColors.primary`. Troca sozinho entre claro/escuro.
extension AppColorsContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

class AppColors {
  AppColors._();
  // Primary
  static const Color primary = Color(0xFF2D54E8);
  static const Color primaryDark = Color(0xFF1A3CC9);
  static const Color primaryLight = Color(0xFFEEF1FD);

  // Background
  static const Color background = Color(0xFFF0F2F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8ECF4);

  // Text
  static const Color textPrimary = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Accent
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Border
  static const Color border = Color(0xFFDDE2EE);
  static const Color borderFocused = Color(0xFF2D54E8);
}

/// Estilos de texto do app. Cada um é um método (não mais `static const`)
/// porque a cor depende do tema ativo (`context.colors`) — precisa do
/// [BuildContext] pra resolver certo em claro/escuro. Uso: `AppTextStyles.
/// bodyMedium(context)`, igual antes só que com `(context)` no final.
class AppTextStyles {
  AppTextStyles._();
  static const String fontFamily = 'Inter';

  static TextStyle displayLarge(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle headlineLarge(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: context.colors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle headlineMedium(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: context.colors.textPrimary,
  );

  static TextStyle titleLarge(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: context.colors.textPrimary,
  );

  static TextStyle titleMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: context.colors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: context.colors.textPrimary,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: context.colors.textPrimary,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: context.colors.textSecondary,
  );

  static TextStyle labelLarge(BuildContext context) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: context.colors.textSecondary,
    letterSpacing: 1.0,
  );

  static TextStyle labelMedium(BuildContext context) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: context.colors.textSecondary,
    letterSpacing: 0.8,
  );
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 64;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}
