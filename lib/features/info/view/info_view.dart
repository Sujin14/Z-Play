import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app/app_name.dart';
import '../../../core/services/app_info_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../model/info_page_model.dart';
import '../widgets/info_header.dart';
import '../widgets/info_section_card.dart';

class InfoView extends StatelessWidget {
  const InfoView({super.key, required this.kind});

  final InfoKind kind;

  @override
  Widget build(BuildContext context) {
    final version = context.read<AppInfoService>().version;
    final page = InfoPage.of(kind, version: version);
    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            12,
            AppSpacing.screen,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            InfoHeader(title: page.title, lastUpdated: page.lastUpdated),
            const SizedBox(height: 24),
            for (final section in page.sections) ...[
              InfoSectionCard(
                section: section,
                onAction: switch (section.action) {
                  InfoAction.licenses => () => showLicensePage(
                        context: context,
                        applicationName: appName,
                        applicationVersion: version,
                      ),
                  null => null,
                },
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}
