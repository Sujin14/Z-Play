import 'package:flutter/material.dart';

String appName = "Mp3Player";
String developerName = "Sujin k Suresh";
String gmail = "sujinsuresh1422002@gmail.com";

class PrivacyPolicyPage extends StatelessWidget {
  final List<String> privacyPolicySections = [
    'Introduction: This Privacy Notice for Sujin describes how and why we might access, collect, store, use, and/or share ("process") your personal information when you use our services ("Services"), including when you:\n'
        '- Download and use our mobile application (Z-PLAY), or any other application that links to this Privacy Notice.\n'
        '- Engage with us in other related ways, including any sales, marketing, or events.',
    'Questions or concerns? Reading this Privacy Notice will help you understand your privacy rights and choices. If you still have questions, contact us at $gmail',
    'Summary of Key Points:',
    '1. What Information Do We Collect?',
    'We collect personal information that you voluntarily provide to us when you register on the Services, express an interest in obtaining information about us or our products, when you participate in activities, or when you contact us.',
    '2. How Do We Process Your Information?',
    'We process your personal information to provide, improve, and administer our Services, communicate with you, for security and fraud prevention, and to comply with the law.',
    '3. When and With Whom Do We Share Your Personal Information?',
    'We may share your personal information in connection with a business transfer, during negotiations of a merger or sale, or in specific cases as described in the full Privacy Notice.',
    '4. How Long Do We Keep Your Information?',
    'We keep your information as long as necessary to fulfill the purposes outlined in this Privacy Notice unless otherwise required by law.',
    '5. How Do We Keep Your Information Safe?',
    'We implement reasonable technical and organizational security measures to protect your data, but no electronic transmission is 100% secure.',
    '6. Do We Collect Information From Minors?',
    'We do not knowingly collect or market personal information to children under 18 years of age.',
    '7. What Are Your Privacy Rights?',
    'You may review, change, or terminate your account at any time, depending on your country of residence.',
    '8. Controls for Do-Not-Track Features',
    'We currently do not respond to Do-Not-Track signals from web browsers.',
    '9. Do Other Regions Have Specific Privacy Rights?',
    'You may have additional rights depending on where you live, such as the right to request access to or correction of your personal information.',
    '10. Do We Make Updates to This Notice?',
    'Yes, we may update this Privacy Notice from time to time. The updated version will have an updated "Last Updated" date.',
  ];

  PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(style: TextStyle(fontSize: hi / 50), 'Privacy Policy'),
      ),
      body: ListView.builder(
        itemCount: privacyPolicySections.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              privacyPolicySections[index],
              style: TextStyle(fontSize: hi / 50),
            ),
          );
        },
      ),
    );
  }
}
