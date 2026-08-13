import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/core/utils/snackbar_utils.dart';
import 'package:autolog_app/domain/entity/user_entity.dart';
import 'package:autolog_app/ui/cubit/theme/theme_cubit.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProfileCubit>();
    _cubit.loadUser();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(title: const AppBrandTitle(), centerTitle: true),
        body: SafeArea(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                showAppSnackBar(context, state.message, isError: true);
              }
              if (state is ProfileSignedOut) {
                getIt<VehicleListCubit>().reset();
                getIt<HomeCubit>().reset();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return _ProfileContent(
                  user: state.user,
                  onSignOut: () => _cubit.signOut(),
                );
              }
              if (state is ProfileError) {
                return _ProfileErrorMessage(message: state.message);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorMessage extends StatelessWidget {
  final String message;

  const _ProfileErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(context),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onSignOut;

  const _ProfileContent({required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _Avatar(user: user),
          const SizedBox(height: AppSpacing.lg),
          Text(user.name, style: AppTextStyles.headlineLarge(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _AppVersionCard(),
          const SizedBox(height: AppSpacing.lg),
          const _ThemeModeCard(),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onSignOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.error,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                AppStrings.signOutButton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final UserEntity user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrl;

    if (photoUrl == null) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: context.colors.primaryLight,
        child: Icon(Icons.person, size: 48, color: context.colors.primary),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        placeholder: (context, url) => ColoredBox(
          color: context.colors.primaryLight,
          child: Icon(Icons.person, size: 48, color: context.colors.primary),
        ),
        errorWidget: (context, url, error) => ColoredBox(
          color: context.colors.primaryLight,
          child: Icon(Icons.person, size: 48, color: context.colors.primary),
        ),
      ),
    );
  }
}

/// Linha padrão das configurações do Perfil: ícone + label à esquerda,
/// algum controle (texto, switch etc.) à direita. Usada por [_AppVersionCard]
/// e [_ThemeModeCard], que só diferem no [trailing].
class _ProfileSettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _ProfileSettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.titleMedium(context)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _AppVersionCard extends StatelessWidget {
  const _AppVersionCard();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '...';
        return _ProfileSettingRow(
          icon: Icons.info_outline_rounded,
          label: AppStrings.appVersionLabel,
          trailing: Text(
            version,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      bloc: getIt<ThemeCubit>(),
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        return _ProfileSettingRow(
          icon: Icons.dark_mode_outlined,
          label: AppStrings.themeSectionLabel,
          trailing: SizedBox(
            height: 24,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: isDark,
                activeThumbColor: context.colors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (value) => getIt<ThemeCubit>().changeThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
