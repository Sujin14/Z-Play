import 'package:flutter/material.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/navigation/router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Settings",
            style: TextStyle(
                fontSize: hi / 45, color: theme.textTheme.bodyLarge!.color)),
      ),
      body: ListView(
        children: [
          _tile(context, Icons.history, "Recently Played",
              AppRoutes.recentlyPlayed, hi),
          _divider(context),
          _tile(context, Icons.watch_later, "Most Played", AppRoutes.mostPlayed,
              hi),
          _divider(context),
          _tile(context, Icons.info, "About", AppRoutes.about, hi),
          _divider(context),
          _tile(context, Icons.privacy_tip, "Privacy Policy",
              AppRoutes.privacyPolicy, hi),
          _divider(context),
          _tile(context, Icons.description, "Terms & Conditions",
              AppRoutes.termsConditions, hi),
          const SizedBox(
            height: 250,
          ),
          Center(
              child: Text("Version 1.0.1",
                  style: TextStyle(
                      fontSize: hi / 55, color: theme.colorScheme.surface)))
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(color: Theme.of(context).colorScheme.surface);

  Widget _tile(
      BuildContext ctx, IconData icon, String text, String route, double hi) {
    final theme = Theme.of(ctx);
    return ListTile(
      leading: Icon(icon, color: theme.textTheme.bodyLarge!.color),
      title: Text(text,
          style: TextStyle(
              fontSize: hi / 50, color: theme.textTheme.bodyLarge!.color)),
      onTap: () => NavigationService.pushNamed(route),
    );
  }
}
