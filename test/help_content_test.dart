import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/app/app_name.dart';
import 'package:musicplayer/core/services/platform_capabilities.dart';
import 'package:musicplayer/core/utils/support_contact.dart';
import 'package:musicplayer/features/help/model/help_content.dart';
import 'package:musicplayer/features/help/view_model/help_view_model.dart';

void main() {
  // Android has folders and a playback notification; iOS has neither.
  List<String> answers({required bool android}) => [
        for (final faq in HelpViewModel(
          openIndex: null,
          capabilities: PlatformCapabilities(
            supportsFolders: android,
            hasPlaybackNotification: android,
          ),
        ).faqs)
          faq.answer.toLowerCase(),
      ];

  test('Help lists 7 questions on Android and 6 on iOS', () {
    expect(answers(android: true), hasLength(7), reason: 'Android');
    expect(answers(android: false), hasLength(6),
        reason: 'iOS has no folder question');
  });

  test('iOS answers never mention hidden folders', () {
    for (final answer in answers(android: false)) {
      expect(answer, isNot(contains('hidden')));
      expect(answer, isNot(contains('folder')));
    }
  });

  test('only the iOS answer explains cloud-only songs', () {
    final cloud = 'songs that are only in the cloud (for example apple music '
        'streaming or not downloaded to this iphone) cannot be played by '
        '${appName.toLowerCase()}, so download them to your device first.';
    expect(answers(android: false).first, contains(cloud));
    expect(answers(android: true).join(' '), isNot(contains(cloud)));
  });

  test('Android answers keep their folder text unchanged', () {
    final android = answers(android: true);
    expect(android, [
      for (final faq in HelpContent.faqs) faq.answer.toLowerCase(),
    ]);
    for (final index in [0, 1, 2]) {
      expect(android[index], contains('hidden'));
      expect(android[index], contains('folder'));
    }
  });

  group('background playback', () {
    const question = 'Does music keep playing when I lock my phone?';
    String answerTo(bool android) {
      final faqs = HelpViewModel(
        openIndex: null,
        capabilities: PlatformCapabilities(
          supportsFolders: android,
          hasPlaybackNotification: android,
        ),
      ).faqs;
      return faqs.singleWhere((faq) => faq.question == question).answer;
    }

    test('the question follows the sleep timer one on both platforms', () {
      for (final android in [true, false]) {
        final questions = [
          for (final faq in HelpViewModel(
            openIndex: null,
            capabilities: PlatformCapabilities(
              supportsFolders: android,
              hasPlaybackNotification: android,
            ),
          ).faqs)
            faq.question,
        ];
        final sleep = questions
            .indexOf('How do the sleep timer and playback speed work?');
        expect(questions[sleep + 1], question);
      }
    });

    test('Android mentions the notification and its 10-second buttons', () {
      final answer = answerTo(true);
      expect(answer, contains('10-second back and forward buttons'));
      expect(answer, contains('swipe the notification away'));
    });

    test('iOS mentions the lock screen and Control Center, not a notification',
        () {
      final answer = answerTo(false);
      expect(answer, contains('lock your iPhone'));
      expect(answer, contains('Control Center'));
      expect(answer, isNot(contains('10-second')));
      expect(answer, isNot(contains('notification')));
    });

    test('the sleep timer answer says it keeps running with the screen off',
        () {
      for (final android in [true, false]) {
        expect(
          answers(android: android).join(' '),
          contains('the sleep timer keeps running while the screen is off.'),
        );
      }
    });
  });

  test('no email address is written in lib/ outside the support constant', () {
    const constantFile = 'lib/core/utils/support_contact.dart';
    final emailPattern = RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+');
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll('\\', '/');
      if (path == constantFile) continue;
      final source = entity.readAsStringSync();
      if (source.contains(supportEmail) || emailPattern.hasMatch(source)) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty);
  });
}
