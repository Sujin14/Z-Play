class FaqItem {
  const FaqItem({
    required this.question,
    required this.answer,
    this.answerWithoutFolders,
    this.aboutFolders = false,
  });

  final String question;
  final String answer;
  // Shown instead of answer where the platform has no folders (iOS), when
  // the answer mentions them.
  final String? answerWithoutFolders;
  // Left out where the platform has no folders (iOS).
  final bool aboutFolders;
}
