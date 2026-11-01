import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/navigation/now_playing_route.dart';
import 'package:musicplayer/core/theme/app_radii.dart';
import 'package:musicplayer/core/theme/app_tokens.dart';

void main() {
  const miniRect = Rect.fromLTWH(16, 600, 368, 64);

  Future<NowPlayingRoute<void>> pushRoute(WidgetTester tester,
      {bool disableAnimations = false}) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: const [AppTokens.dark]),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: const SizedBox.shrink(),
    ));
    final route = NowPlayingRoute<void>(
      builder: (context) => const SizedBox.expand(),
      anchor: (screen, padding) => miniRect,
    );
    tester.state<NavigatorState>(find.byType(Navigator)).push(route);
    await tester.pump();
    return route;
  }

  RRect clipNow(WidgetTester tester) {
    final finder = find.byKey(NowPlayingRoute.morphKey, skipOffstage: false);
    final clip = tester.widget<ClipRRect>(finder).clipper!;
    return clip.getClip(tester.getSize(finder));
  }

  testWidgets('starts on the mini player rect and ends on the full screen',
      (tester) async {
    await pushRoute(tester);

    final start = clipNow(tester);
    expect(start.outerRect, miniRect);
    expect(start.tlRadiusX, AppRadii.miniPlayer);

    await tester.pumpAndSettle();

    final end = clipNow(tester);
    final screen = Offset.zero &
        tester
            .getSize(find.byKey(NowPlayingRoute.morphKey, skipOffstage: false));
    expect(end.outerRect, screen);
    expect(end.tlRadiusX, 0);
  });

  double contentOpacity(WidgetTester tester) {
    final fade = tester.widget<FadeTransition>(find.byWidgetPredicate(
      (widget) => widget is FadeTransition && widget.child is RepaintBoundary,
      skipOffstage: false,
    ));
    return fade.opacity.value;
  }

  testWidgets('each direction takes 750ms', (tester) async {
    final route = await pushRoute(tester);

    expect(route.transitionDuration, const Duration(milliseconds: 750));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 750));
  });

  testWidgets('content fades in mid-growth and out early on close',
      (tester) async {
    final route = await pushRoute(tester);

    // 35% and 85% of 750ms are 262.5ms and 637.5ms.
    await tester.pump(const Duration(milliseconds: 255));
    expect(contentOpacity(tester), 0);
    await tester.pump(const Duration(milliseconds: 390));
    expect(contentOpacity(tester), 1);
    await tester.pumpAndSettle();

    route.navigator!.pop();
    await tester.pump();
    // 40% of 750ms is 300ms.
    await tester.pump(const Duration(milliseconds: 305));
    expect(contentOpacity(tester), 0);
    await tester.pumpAndSettle();
  });

  testWidgets('closing lands back on the mini player rect', (tester) async {
    final route = await pushRoute(tester);
    await tester.pumpAndSettle();

    route.navigator!.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 749));

    expect(clipNow(tester).outerRect.top, closeTo(miniRect.top, 1));
    await tester.pumpAndSettle();
    expect(find.byKey(NowPlayingRoute.morphKey, skipOffstage: false),
        findsNothing);
  });

  testWidgets('reduced motion uses a short fade instead of the morph',
      (tester) async {
    final route = await pushRoute(tester, disableAnimations: true);

    expect(find.byKey(NowPlayingRoute.fadeKey, skipOffstage: false),
        findsOneWidget);
    expect(find.byKey(NowPlayingRoute.morphKey, skipOffstage: false),
        findsNothing);
    expect(route.transitionDuration, const Duration(milliseconds: 150));
    expect(route.reverseTransitionDuration, const Duration(milliseconds: 150));
  });
}
