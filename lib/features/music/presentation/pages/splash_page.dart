// lib/features/music/presentation/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/navigation/router.dart';
import '../../../../core/permissions/permissions_handler.dart';
import '../../../../constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final musicVM = Provider.of<MusicViewModel>(context, listen: false);
    bool granted = await PermissionsHandler.requestStoragePermission();
    if (granted) {
      await musicVM.requestStoragePermissionAndFetchFiles();
    }
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    NavigationService.pushReplacementNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.colorScheme.gradientStart, theme.colorScheme.gradientEnd])),
        child: SafeArea(
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Lottie.asset('assets/json/splash.json', width: 240, height: 240, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Image.asset('assets/images/logo.png', width: 220, height: 80, fit: BoxFit.contain),
            ]),
          ),
        ),
      ),
    );
  }
}