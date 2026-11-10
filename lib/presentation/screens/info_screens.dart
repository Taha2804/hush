import 'package:flutter/material.dart';

import '../widgets/common.dart';
import '../widgets/mascot.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (Icons.group_add_rounded, l.how1Title, l.how1Body),
      (Icons.style_rounded, l.how2Title, l.how2Body),
      (Icons.record_voice_over_rounded, l.how3Title, l.how3Body),
      (Icons.how_to_vote_rounded, l.how4Title, l.how4Body),
      (Icons.emoji_objects_rounded, l.how5Title, l.how5Body),
      (Icons.theater_comedy_rounded, l.howModesTitle, l.howModesBody),
      (Icons.keyboard_rounded, l.howKeysTitle, l.howKeysBody),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.howTitle)),
      body: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Body(
          child: Column(children: [
            const SizedBox(height: 8),
            Mascot(size: 100, mood: MascotMood.happy, semanticLabel: l.mascotLabel),
            const SizedBox(height: 12),
            for (final (icon, title, body) in items) ...[
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text(body)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ]),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  static const appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(padding: const EdgeInsets.only(bottom: 24), children: [
        Body(
          child: Column(children: [
            const SizedBox(height: 12),
            Mascot(size: 130, semanticLabel: l.mascotLabel),
            Text(l.appTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            Text(l.tagline),
            Text(l.version(appVersion), style: TextStyle(color: cs.outline)),
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(l.aboutFree, textAlign: TextAlign.center))),
            SectionTitle(l.aboutCredits),
            Card(
              child: Column(children: [
                ListTile(leading: const Icon(Icons.public_rounded), title: Text(l.creditWikipedia)),
                ListTile(leading: const Icon(Icons.hub_rounded), title: Text(l.creditConceptNet)),
                ListTile(leading: const Icon(Icons.manage_search_rounded), title: Text(l.creditDatamuse)),
                ListTile(leading: const Icon(Icons.inventory_2_rounded), title: Text(l.creditPacks)),
              ]),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => showLicensePage(context: context, applicationName: l.appTitle, applicationVersion: appVersion),
              child: const Text('Open-source licences'),
            ),
          ]),
        ),
      ]),
    );
  }
}
