import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/state/library_view_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/state/playlist_view_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../view_model/splash_view_model.dart';
import '../widgets/splash_animation.dart';
import '../widgets/splash_wordmark.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final SplashViewModel _splash;

  // Light icons and a dark navigation bar on the always-dark splash. Inside
  // the app's own region, so the theme's style comes back as soon as the
  // splash leaves the tree.
  static const _systemBars = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.dBase,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  @override
  void initState() {
    super.initState();
    _splash = SplashViewModel.forApp(
      library: context.read<LibraryViewModel>(),
      playlists: context.read<PlaylistViewModel>(),
      player: context.read<PlayerViewModel>(),
    );
    // The library load notifies listeners straight away, which isn't allowed
    // while the first frame is still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _splash.start();
    });
  }

  @override
  void dispose() {
    _splash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    // Always the dark gradient, matching the native launch color; the
    // Lottie's white strokes vanish on the light one. The shell after it
    // uses the chosen theme.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemBars,
      child: Theme(
        data: Theme.of(context).copyWith(extensions: const [AppTokens.dark]),
        child: GradientScaffold(
          body: SafeArea(
            // One centered group, so the Lottie and the name stay centered
            // together; on very short screens it scales down instead of
            // overflowing.
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SplashAnimation(
                      play: !reducedMotion,
                      onLoaded: () =>
                          _splash.animationLoaded(reducedMotion: reducedMotion),
                      onFinished: _splash.animationFinished,
                      onFailed: _splash.animationFailed,
                    ),
                    const SizedBox(height: 24),
                    const SplashWordmark(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
