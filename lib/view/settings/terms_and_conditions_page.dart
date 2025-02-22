import 'package:flutter/material.dart';

String appName = "Z-PLAY";
String developerName = "Sujin K Suresh";
String gmail = "sujinsuresh1422002@gmail.com";

class TermsAndConditionsPage extends StatelessWidget {
  final List<String> termsAndConditionsSections = [
    '1. Introduction',
    'Welcome to $appName! These Terms and Conditions govern your use of our application and services. By using the app, you agree to comply with and be bound by these terms.',
    '2. Acceptance of Terms',
    'By accessing or using $appName, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.',
    '3. User Responsibilities',
    'You agree to use the app only for lawful purposes. You must not misuse, modify, distribute, or copy any part of the application without proper authorization.',
    '4. Intellectual Property',
    'All content, trademarks, and materials available on $appName are owned by $developerName. You may not reproduce, distribute, or create derivative works without permission.',
    '5. Limitation of Liability',
    '$appName and its developers shall not be held liable for any direct, indirect, incidental, or consequential damages resulting from the use or inability to use the application.',
    '6. Privacy Policy',
    'Your use of $appName is also governed by our Privacy Policy. Please review it to understand how we collect, use, and protect your data.',
    '7. Termination of Service',
    'We reserve the right to terminate or restrict access to $appName for any user who violates these terms or engages in unlawful activities.',
    '8. Changes to Terms',
    'We may update these Terms and Conditions from time to time. Any changes will be reflected in the updated version of this document.',
    '9. Contact Information',
    'For any questions regarding these terms, you can contact us at $gmail.',
  ];

  TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: TextStyle(fontSize: hi / 50),
        ),
      ),
      body: ListView.builder(
        itemCount: termsAndConditionsSections.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              termsAndConditionsSections[index],
              style: TextStyle(fontSize: hi / 50),
            ),
          );
        },
      ),
    );
  }
}
