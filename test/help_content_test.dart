import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/app/app_name.dart';
import 'package:musicplayer/core/services/platform_capabilities.dart';
import 'package:musicplayer/core/utils/support_contact.dart';
import 'package:musicplayer/features/help/model/help_content.dart';
import 'package:musicplayer/features/help/view_model/help_view_model.dart';

void main() {
  List<String> answers({required bool supportsFolders}) => [
        for (final faq in HelpViewModel(
          openIndex: null,
          capabilities: PlatformCapabilities(supportsFolders: supportsFolders),
        ).faqs)
          faq.answer.toLowerCase(),
      ];

  test('Help lists 6 questions on Android and 5 on iOS', () {
    expect(answers(supportsFolders: true), hasLength(6), reason: 'Android');
    expect(answers(supportsFolders: false), hasLength(5),
        reason: 'iOS has no folder question');
  });

  test('iOS answers never mention hidden folders', () {
    for (final answer in answers(supportsFolders: false)) {
      expect(answer, isNot(contains('hidden')));
      expect(answer, isNot(contains('folder')));
    }
  });

  test('only the iOS answer explains cloud-only songs', () {
    final cloud = 'songs that are only in the cloud (for example apple music '
        'streaming or not downloaded to this iphone) cannot be played by '
        '${appName.toLowerCase()}, so download them to your device first.';
    expect(answers(supportsFolders: false).first, contains(cloud));
    expect(answers(supportsFolders: true).join(' '), isNot(contains(cloud)));
  });

  test('Android answers keep their folder text unchanged', () {
    final android = answers(supportsFolders: true);
    expect(android, [
      for (final faq in HelpContent.faqs) faq.answer.toLowerCase(),
    ]);
    for (final index in [0, 1, 2]) {
      expect(android[index], contains('hidden'));
      expect(android[index], contains('folder'));
    }
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
