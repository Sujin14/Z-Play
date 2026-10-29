import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/library_view_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/state/playlist_view_model.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/wordmark.dart';
import '../view_model/splash_view_model.dart';
import '../widgets/loading_stripe.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  static const double _logoSize = 120;
  static const double _wordmarkSize = 46;

  @override
  void initState() {
    super.initState();
    SplashViewModel(
      library: context.read<LibraryViewModel>(),
      playlists: context.read<PlaylistViewModel>(),
      player: context.read<PlayerViewModel>(),
    ).openLibrary(isShown: () => mounted);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LogoMark(size: _logoSize, rings: true),
                      const SizedBox(height: 28),
                      const Wordmark(fontSize: _wordmarkSize),
                      const SizedBox(height: 8),
                      Text(
                        'Offline music, on this device',
                        style: text.bodyLarge
                            ?.copyWith(color: AppTokens.of(context).text2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const LoadingStripe(),
            const SizedBox(height: 14),
            Text('Scanning your library…', style: text.bodyMedium),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
