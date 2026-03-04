import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/app_settings_controller.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatelessWidget {
  final AppSettingsController settingsController;

  const SettingsScreen({
    super.key,
    required this.settingsController,
  });

  String _formatTime(BuildContext context, TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(settingsController.tr('Settings', 'སྒྲིག་འགོད།')),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                settingsController.tr('Interface Language', 'བརྗོད་སྐད།'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<InterfaceLanguage>(
                segments: [
                  ButtonSegment(
                    value: InterfaceLanguage.english,
                    label: Text(settingsController.tr('English', 'ཨིན་ཡིག')),
                  ),
                  ButtonSegment(
                    value: InterfaceLanguage.tibetan,
                    label: Text(settingsController.tr('Tibetan', 'བོད་ཡིག')),
                  ),
                ],
                selected: {settingsController.interfaceLanguage},
                onSelectionChanged: (selection) {
                  settingsController.setInterfaceLanguage(selection.first);
                },
              ),
              const SizedBox(height: 24),
              Text(
                settingsController.tr('Appearance', 'མཐོང་སྣང་།'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ThemeMode>(
                value: settingsController.themeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(settingsController.tr('System', 'མ་ལག')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(settingsController.tr('Light', 'འོད་མདངས།')),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(settingsController.tr('Dark', 'མུན་མདངས།')),
                  ),
                ],
                onChanged: (mode) {
                  if (mode != null) {
                    settingsController.setThemeMode(mode);
                  }
                },
                decoration: InputDecoration(
                  labelText: settingsController.tr('Theme Mode', 'བརྗོད་སྟངས་མདངས།'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                settingsController.tr('Practice Reminder', 'སྦྱོང་བ་ཉེན་བརྡ།'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(settingsController.tr('Enable daily reminder', 'ཉིན་རེའི་དྲན་སྐུལ་སྒྲིག')),
                value: settingsController.reminderEnabled,
                onChanged: (enabled) {
                  settingsController.setReminderEnabled(enabled);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(settingsController.tr('Reminder time', 'དྲན་སྐུལ་དུས་ཚོད།')),
                subtitle: Text(_formatTime(context, settingsController.reminderTime)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settingsController.reminderTime,
                  );
                  if (picked != null) {
                    await settingsController.setReminderTime(picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                settingsController.tr('About', 'སྐོར།'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(settingsController.tr('Created by', 'བཟོ་མཁན།')),
                subtitle: const Text('ta4tsering.com'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(
                  Uri.parse('https://ta4tsering.com'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_outlined),
                title: Text(settingsController.tr('Contact', 'འབྲེལ་གཏུག')),
                subtitle: Text(settingsController.tr(
                  'Report incorrect answers or collaborate',
                  'ལན་ནོར་བཟོད་གསོལ་དང་མཉམ་ལས་སྐོར།',
                )),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(
                  Uri.parse('mailto:ta3tsering@gmail.com?subject=TSP Test App Feedback'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
