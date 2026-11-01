import '../../../core/app/app_name.dart';
import 'faq_item.dart';

class HelpContent {
  static const title = 'Help';
  static const subtitle = 'Answers to common questions';
  static const contactEyebrow = 'STILL NEED HELP?';
  static const contactMessage = 'Write to us and we will get back to you.';
  static const copyEmailLabel = 'Copy email';
  static const emailCopied = 'Email address copied';

  static const faqs = [
    FaqItem(
      question: 'Why can\'t I see my songs?',
      answer:
          '$appName reads the music already on your device. Make sure you have allowed access to audio files, either when the app first asks or later in your phone\'s Settings, under $appName, then permissions (on iPhone: Media & Apple Music). Then open Settings in $appName and tap Rescan storage. Songs inside folders you have hidden will not appear. Clips under 60 seconds and ringtones, alarms and notification sounds are also hidden unless you turn them on in Settings.',
      answerWithoutFolders:
          '$appName reads the music already on your device. Make sure you have allowed access to audio files, either when the app first asks or later in your phone\'s Settings, under $appName, then permissions (on iPhone: Media & Apple Music). Then open Settings in $appName and tap Rescan storage. Clips under 60 seconds are left out unless you turn them on in Settings. Songs that are only in the cloud (for example Apple Music streaming or not downloaded to this iPhone) cannot be played by $appName, so download them to your device first.',
    ),
    FaqItem(
      question: 'I added new songs. How do I make them appear?',
      answer:
          'Open Settings and tap Rescan storage. The library refreshes and your new songs appear in a few moments. If a song still does not show up, check that its folder is not hidden.',
      answerWithoutFolders:
          'Open Settings and tap Rescan storage. The library refreshes and your new songs appear in a few moments.',
    ),
    FaqItem(
      question: 'How do I hide a folder, and how do I bring it back?',
      aboutFolders: true,
      answer:
          'Open the Folders tab in your library and tap the hide button (the crossed-out eye) on a folder. Its songs disappear from the library. To bring a folder back, open Settings, tap Hidden folders and tap the eye button (Show folder) next to it.',
    ),
    FaqItem(
      question: 'How do I create, rename or delete a playlist?',
      answer:
          'Open the Playlists tab and tap New to create one. Tap the three dots on a playlist to rename or delete it. You can also open a playlist and tap the edit icon to change its name and choose which songs it contains. Deleting a playlist never deletes the songs from your device.',
    ),
    FaqItem(
      question: 'How do the sleep timer and playback speed work?',
      answer:
          'Open Now Playing. Tap Sleep timer to pause playback after 15, 30, 45 or 60 minutes, or at the end of the current track. Tap the speed button (it shows the current speed, such as 1x) to play at 0.75x, 1x, 1.25x, 1.5x or 2x. The sleep timer keeps running while the screen is off.',
    ),
    FaqItem(
      question: 'Does music keep playing when I lock my phone?',
      answer:
          'Yes. $appName keeps playing when you lock your phone or open another app. You can control playback from the notification, which also has 10-second back and forward buttons, from the lock screen and with headset or Bluetooth buttons. To stop completely, pause playback and swipe the notification away.',
      answerWithoutNotification:
          'Yes. $appName keeps playing when you lock your iPhone or open another app. You can control playback from the lock screen and Control Center, and with headphone buttons. To stop completely, pause playback.',
    ),
    FaqItem(
      question: 'Does $appName collect my data or need the internet?',
      answer:
          'No. $appName works completely offline. It has no accounts, no ads and no analytics. Your playlists, favourites and listening history stay on your device and are removed when you uninstall the app. See the Privacy policy for details.',
    ),
  ];
}
