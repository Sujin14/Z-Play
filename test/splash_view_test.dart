import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:musicplayer/core/app/app_name.dart';
import 'package:musicplayer/core/state/library_view_model.dart';
import 'package:musicplayer/core/state/player_view_model.dart';
import 'package:musicplayer/core/state/playlist_view_model.dart';
import 'package:musicplayer/core/theme/app_colors.dart';
import 'package:musicplayer/core/theme/app_tokens.dart';
import 'package:musicplayer/features/splash/view/splash_view.dart';
import 'package:musicplayer/features/splash/widgets/splash_animation.dart';
import 'package:musicplayer/features/splash/widgets/splash_wordmark.dart';
import 'package:provider/provider.dart';

// The library never finishes loading, so the splash stays put while the test
// looks at it.
class _StubLibrary implements LibraryViewModel {
  @override
  Future<void> load() => Completer<void>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubPlaylists implements PlaylistViewModel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubPlayer implements PlayerViewModel {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, {AppTokens tokens = AppTokens.dark}) => MaterialApp(
      theme: ThemeData(extensions: [tokens]),
      home: home,
    );

Widget _splash({AppTokens tokens = AppTokens.dark}) {
  // The stubs stand in for ChangeNotifiers, which Provider.value would
  // otherwise reject.
  Provider.debugCheckInvalidValueType = null;
  return MultiProvider(
    providers: [
      Provider<LibraryViewModel>.value(value: _StubLibrary()),
      Provider<PlaylistViewModel>.value(value: _StubPlaylists()),
      Provider<PlayerViewModel>.value(value: _StubPlayer()),
    ],
    child: _app(const SplashView(), tokens: tokens),
  );
}

bool _paintsGradient(Widget widget, Gradient gradient) =>
    widget is DecoratedBox &&
    widget.decoration is BoxDecoration &&
    (widget.decoration as BoxDecoration).gradient == gradient;

void main() {
  testWidgets('the wordmark shows the app name', (tester) async {
    await tester.pumpWidget(_app(const Scaffold(body: SplashWordmark())));

    expect(find.text(appName), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('the splash shows the Lottie and the wordmark', (tester) async {
    await tester.pumpWidget(_splash());

    expect(find.byType(SplashAnimation), findsOneWidget);
    expect(find.byType(LottieBuilder), findsOneWidget);
    expect(find.byType(SplashWordmark), findsOneWidget);
    expect(find.text(appName), findsOneWidget);

    // Unmounting cancels the splash and wordmark timers.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final (name, tokens) in [
    ('dark', AppTokens.dark),
    ('light', AppTokens.light),
  ]) {
    testWidgets('the splash uses the dark gradient in the $name theme',
        (tester) async {
      await tester.pumpWidget(_splash(tokens: tokens));

      expect(
        find.byWidgetPredicate(
            (widget) => _paintsGradient(widget, AppColors.darkBg)),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
            (widget) => _paintsGradient(widget, AppColors.lightBg)),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('the splash asks for light status and navigation bars',
      (tester) async {
    await tester.pumpWidget(_splash(tokens: AppTokens.light));

    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(
        of: find.byType(SplashView),
        matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      ),
    );
    expect(region.value.statusBarIconBrightness, Brightness.light);
    expect(region.value.statusBarBrightness, Brightness.dark);
    expect(region.value.statusBarColor, Colors.transparent);
    expect(region.value.systemNavigationBarColor, const Color(0xFF031109));
    expect(region.value.systemNavigationBarIconBrightness, Brightness.light);
    expect(region.value.systemNavigationBarDividerColor, Colors.transparent);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a short screen scales the splash instead of overflowing',
      (tester) async {
    tester.view.physicalSize = const Size(320, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_splash());
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text(appName), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
