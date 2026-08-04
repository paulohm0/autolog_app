import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/routes/main_navigation/main_navigation_screen.dart';
import 'package:autolog_app/ui/routes/main_navigation/vehicle_check_cubit.dart';
import 'package:autolog_app/ui/routes/main_navigation/vehicle_check_state.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_screen.dart';
import 'package:autolog_app/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Exibido logo após um login bem-sucedido: convida o usuário a cadastrar
/// seu primeiro veículo antes de liberar o [MainNavigationScreen], mas
/// permite pular essa etapa (ver [RegisterVehicleScreen.onSkip]).
class MainGate extends StatefulWidget {
  const MainGate({super.key});

  @override
  State<MainGate> createState() => _MainGateState();
}

class _MainGateState extends State<MainGate> {
  late final VehicleCheckCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<VehicleCheckCubit>();
    _cubit.checkVehicles();
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
      child: BlocBuilder<VehicleCheckCubit, VehicleCheckState>(
        builder: (context, state) {
          if (state is VehicleCheckHasVehicles) {
            return const MainNavigationScreen();
          }
          if (state is VehicleCheckNoVehicles) {
            return RegisterVehicleScreen(
              isOnboarding: true,
              onVehicleRegistered: () => _cubit.checkVehicles(),
              onSkip: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              ),
            );
          }
          if (state is VehicleCheckError) {
            return _GateErrorView(
              message: state.message,
              onRetry: () => _cubit.checkVehicles(),
            );
          }
          return const _GateLoadingView();
        },
      ),
    );
  }
}

class _GateLoadingView extends StatelessWidget {
  const _GateLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _GateErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _GateErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: AppStrings.retryButton,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
