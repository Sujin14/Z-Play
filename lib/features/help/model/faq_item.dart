class FaqItem {
  const FaqItem({
    required this.question,
    required this.answer,
    this.answerWithoutFolders,
    this.answerWithoutNotification,
    this.aboutFolders = false,
  });

  final String question;
  final String answer;
  // Shown instead of answer where the platform has no folders (iOS), when
  // the answer mentions them.
  final String? answerWithoutFolders;
  // Shown instead of answer where playback has no notification (iOS).
  final String? answerWithoutNotification;
  // Left out where the platform has no folders (iOS).
  final bool aboutFolders;
}
