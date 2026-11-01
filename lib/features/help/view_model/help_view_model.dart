import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/platform_capabilities.dart';
import '../../../core/utils/support_contact.dart';
import '../../../core/widgets/snack_pill.dart';
import '../model/faq_item.dart';
import '../model/help_content.dart';

class HelpViewModel {
  const HelpViewModel({required this.openIndex, required this.capabilities});

  // Only one answer is open at a time; null when all are closed.
  final int? openIndex;
  final PlatformCapabilities capabilities;

  List<FaqItem> get faqs {
    if (capabilities.supportsFolders) return HelpContent.faqs;
    return [
      for (final faq in HelpContent.faqs)
        if (!faq.aboutFolders)
          FaqItem(
            question: faq.question,
            answer: faq.answerWithoutFolders ?? faq.answer,
          ),
    ];
  }

  String get email => supportEmail;

  bool isOpen(int index) => openIndex == index;

  // The open index after tapping [index]: tapping the open one closes it.
  int? toggled(int index) => isOpen(index) ? null : index;

  Future<void> copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: supportEmail));
    if (!context.mounted) return;
    showSnackPill(context, HelpContent.emailCopied);
  }
}
