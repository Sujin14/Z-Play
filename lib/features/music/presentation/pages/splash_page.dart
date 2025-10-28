import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../viewmodels/music_viewmodel.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/navigation/router.dart';
import '../../../../core/permissions/permissions_handler.dart';

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

    // Always navigate after splash delay
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    NavigationService.pushReplacementNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/json/splash.json',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'assets/images/logo.jpeg',
              width: 350,
              height: 150,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
