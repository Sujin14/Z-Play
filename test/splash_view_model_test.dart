import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/features/splash/view_model/splash_view_model.dart';

void main() {
  late Completer<void> library;
  late int opened;
  late SplashViewModel splash;

  // testWidgets runs on a fake clock, so the timers advance with pump().
  void setUpSplash() {
    library = Completer<void>();
    opened = 0;
    splash = SplashViewModel(
      loadLibrary: () => library.future,
      openMain: () => opened++,
    )..start();
  }

  testWidgets('waits for the library after the animation ends', (tester) async {
    setUpSplash();

    splash.animationFinished();
    await tester.pump();
    expect(opened, 0);

    library.complete();
    await tester.pump();
    expect(opened, 1);
    splash.dispose();
  });

  testWidgets('waits for the animation after the library loads',
      (tester) async {
    setUpSplash();

    library.complete();
    await tester.pump();
    expect(opened, 0);

    splash.animationFinished();
    expect(opened, 1);

    splash.animationFinished();
    expect(opened, 1, reason: 'opens only once');
    splash.dispose();
  });

  testWidgets('a failed animation continues after the fallback delay',
      (tester) async {
    setUpSplash();
    library.complete();
    await tester.pump();

    splash.animationFailed();
    await tester
        .pump(SplashViewModel.fallbackDelay - const Duration(milliseconds: 1));
    expect(opened, 0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(opened, 1);
    splash.dispose();
  });

  testWidgets('reduced motion holds the last frame, then continues',
      (tester) async {
    setUpSplash();
    library.complete();
    await tester.pump();

    splash.animationLoaded(reducedMotion: true);
    await tester.pump(
        SplashViewModel.reducedMotionHold - const Duration(milliseconds: 1));
    expect(opened, 0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(opened, 1);
    splash.dispose();
  });

  testWidgets('never gets stuck if the animation reports nothing',
      (tester) async {
    setUpSplash();
    library.complete();
    await tester.pump(SplashViewModel.maxAnimationWait);

    expect(opened, 1);
    splash.dispose();
  });

  testWidgets('does not navigate after the splash is closed', (tester) async {
    setUpSplash();
    splash.animationFinished();
    splash.dispose();

    library.complete();
    await tester.pump();
    expect(opened, 0);
  });
}
