import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(children: [
        _Group(title: 'Appearance', items: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text(AppStrings.darkMode),
            trailing: Switch(
              value: isDark,
              onChanged: (v) => ref.read(themeModeProvider.notifier).state =
                  v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          ListTile(leading: const Icon(Icons.language_outlined),
              title: const Text(AppStrings.language),
              trailing: const Text('English', style: TextStyle(color: AppColors.grey500))),
        ]),
        const SizedBox(height: 8),
        _Group(title: 'Notifications', items: [
          _SwitchTile(icon: Icons.notifications_outlined, label: 'Push Notifications', value: true),
          _SwitchTile(icon: Icons.email_outlined, label: 'Email Notifications', value: true),
          _SwitchTile(icon: Icons.sms_outlined, label: 'SMS Alerts', value: false),
        ]),
        const SizedBox(height: 8),
        _Group(title: 'Privacy & Security', items: [
          ListTile(leading: const Icon(Icons.lock_outline_rounded), title: const Text('Change Password'), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400)),
          ListTile(leading: const Icon(Icons.fingerprint_rounded), title: const Text('Biometric Login'), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400)),
          ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400)),
        ]),
        const SizedBox(height: 8),
        _Group(title: 'Account', items: [
          ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Account', style: TextStyle(color: AppColors.error)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400)),
        ]),
        const SizedBox(height: 24),
        Center(child: Text('Version 1.0.0', style: TextStyle(color: AppColors.grey400, fontSize: 12))),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _Group extends StatelessWidget {
  final String title; final List<Widget> items;
  const _Group({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).cardColor,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16,14,16,6),
          child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey500))),
      ...items,
    ]),
  );
}

class _SwitchTile extends StatefulWidget {
  final IconData icon; final String label; final bool value;
  const _SwitchTile({required this.icon, required this.label, required this.value});
  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}
class _SwitchTileState extends State<_SwitchTile> {
  late bool _val;
  @override
  void initState() { super.initState(); _val = widget.value; }
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(widget.icon),
    title: Text(widget.label),
    trailing: Switch(value: _val, onChanged: (v) => setState(() => _val = v)),
  );
}
