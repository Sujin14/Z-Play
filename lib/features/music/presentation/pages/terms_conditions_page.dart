import 'package:flutter/material.dart';
import '../../../../constants/themes.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style:
              style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Z-PLAY Terms & Conditions',
                style: style(fontSize: hi / 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Last updated: October 25, 2025\n\n'
                'By using Z-PLAY, you agree to the following terms and conditions. '
                'Please read them carefully.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                '1. Use of the App',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'Z-PLAY is provided for personal, non-commercial use to play and manage local music files. '
                'You agree not to use the app for any illegal or unauthorized purpose.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                '2. Intellectual Property',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'All content and features of Z-PLAY are the property of the Z-PLAY Team. '
                'You may not modify, distribute, or reproduce the app without permission.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                '3. Limitation of Liability',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'Z-PLAY is provided "as is" without warranties. '
                'We are not liable for any damages resulting from the use or inability to use the app.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                '4. Contact Us',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'For questions or concerns, contact us at support@zplay.com.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
