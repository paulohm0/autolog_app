import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/domain/entity/user_entity.dart';
import 'package:autolog_app/ui/routes/profile/profile_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_state.dart';
import 'package:autolog_app/ui/widgets/app_brand_title.dart';
import 'package:autolog_app/ui/widgets/section_card.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const AppBrandTitle(), centerTitle: true),
        body: SafeArea(
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is ProfileLoaded) return _buildProfile(state.user);
              if (state is ProfileError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(UserEntity user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _buildAvatar(user),
          const SizedBox(height: AppSpacing.lg),
          Text(user.name, style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildAppVersion(),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _cubit.signOut(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
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

  Widget _buildAvatar(UserEntity user) {
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: user.photoUrl != null
          ? NetworkImage(user.photoUrl!)
          : null,
      child: user.photoUrl == null
          ? const Icon(Icons.person, size: 48, color: AppColors.primary)
          : null,
    );
  }

  Widget _buildAppVersion() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '...';
        return SectionCard(
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.appVersionLabel,
                style: AppTextStyles.titleMedium,
              ),
              const Spacer(),
              Text(
                version,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
