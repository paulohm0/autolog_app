import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/routes/home/home_screen.dart';
import 'package:autolog_app/ui/routes/oil_battery/oil_battery_screen.dart';
import 'package:autolog_app/ui/routes/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeScreen(),
    OilBatteryScreen(),
    ProfileScreen(),
  ];

  // Mantém o IndexedStack (telas nunca são recriadas ao trocar de aba) mas
  // também aceita arrastar a tela pros lados pra trocar de aba, além do
  // toque no bottom nav.
  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -200 && _selectedIndex < _screens.length - 1) {
      setState(() => _selectedIndex++);
    } else if (velocity > 200 && _selectedIndex > 0) {
      setState(() => _selectedIndex--);
    }
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.exitAppConfirmTitle),
        content: const Text(AppStrings.exitAppConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.exitAppButton,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePop,
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: IndexedStack(index: _selectedIndex, children: _screens),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.surface,
          selectedItemColor: context.colors.primary,
          unselectedItemColor: context.colors.textSecondary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: AppStrings.navHistoryLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              label: AppStrings.navOilBatteryLabel,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: AppStrings.navProfileLabel,
            ),
          ],
        ),
      ),
    );
  }
}
