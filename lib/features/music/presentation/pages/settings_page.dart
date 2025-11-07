import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/navigation/router.dart';
import '../../../../constants/themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Settings",
              style: TextStyle(
                  fontSize: hi / 45, color: theme.textTheme.bodyLarge!.color))),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          theme.colorScheme.gradientStart,
          theme.colorScheme.gradientEnd
        ])),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _glassTile(context, Icons.history, "Recently Played",
                  AppRoutes.recentlyPlayed, hi),
              _divider(context),
              _glassTile(context, Icons.watch_later, "Most Played",
                  AppRoutes.mostPlayed, hi),
              _divider(context),
              _glassTile(context, Icons.info, "About", AppRoutes.about, hi),
              _divider(context),
              _glassTile(context, Icons.privacy_tip, "Privacy Policy",
                  AppRoutes.privacyPolicy, hi),
              _divider(context),
              _glassTile(context, Icons.description, "Terms & Conditions",
                  AppRoutes.termsConditions, hi),
              const SizedBox(height: 180),
              Center(
                  child: Text("Version 1.0.2",
                      style: TextStyle(
                          fontSize: 14, color: theme.textTheme.bodyLarge!.color))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Divider(color: Theme.of(context).colorScheme.surface);

  Widget _glassTile(
      BuildContext ctx, IconData icon, String text, String route, double hi) {
    final theme = Theme.of(ctx);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
                color: theme.colorScheme.glassFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.glassBorder)),
            child: ListTile(
              leading: Icon(icon, color: theme.textTheme.bodyLarge!.color),
              title: Text(text,
                  style: TextStyle(
                      fontSize: hi / 50,
                      color: theme.textTheme.bodyLarge!.color)),
              onTap: () => NavigationService.pushNamed(route),
            ),
          ),
        ),
      ),
    );
  }
}
