import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/platform_capabilities.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../model/help_content.dart';
import '../view_model/help_view_model.dart';
import '../widgets/faq_tile.dart';
import '../widgets/help_contact_card.dart';
import '../widgets/help_header.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    final help = HelpViewModel(
      openIndex: _openIndex,
      capabilities: context.read<PlatformCapabilities>(),
    );
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: HelpHeader(
                title: HelpContent.title,
                subtitle: HelpContent.subtitle,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                0,
                AppSpacing.screen,
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.list(
                children: [
                  for (final (index, item) in help.faqs.indexed) ...[
                    FaqTile(
                      item: item,
                      open: help.isOpen(index),
                      onTap: () =>
                          setState(() => _openIndex = help.toggled(index)),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                  HelpContactCard(
                    eyebrow: HelpContent.contactEyebrow,
                    message: HelpContent.contactMessage,
                    email: help.email,
                    copyLabel: HelpContent.copyEmailLabel,
                    onCopy: () => help.copyEmail(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
