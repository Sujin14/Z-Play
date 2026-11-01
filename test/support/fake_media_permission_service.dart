import 'dart:async';

import 'package:musicplayer/core/models/media_access_model.dart';
import 'package:musicplayer/core/services/media_permission_service.dart';

// Answers with [answer], or waits for [prompt] when one is given, the way the
// system dialog waits for the user.
class FakeMediaPermissionService implements MediaPermissionService {
  FakeMediaPermissionService({this.answer = MediaAccess.granted, this.prompt});

  final MediaAccess answer;
  final Completer<MediaAccess>? prompt;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<MediaAccess> request() {
    requests++;
    return prompt?.future ?? Future.value(answer);
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}
