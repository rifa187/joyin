import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../widgets/settings_item.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  String _notificationFrequency = 'Real-time';
  bool _emailNotif = true;
  bool _pushNotif = true;
  bool _smsNotif = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SettingsItem(
                title: 'Notifikasi Email',
                subtitle: 'Terima notifikasi melalui email',
                trailing: Switch(
                  value: _emailNotif, 
                  onChanged: (v) => setState(() => _emailNotif = v), 
                  activeThumbColor: AppColors.joyin
                ),
              ),
              const Divider(height: 20, thickness: 1),
              SettingsItem(
                title: 'Push Notifications',
                subtitle: 'Terima pemberitahuan langsung dari website',
                trailing: Switch(
                  value: _pushNotif, 
                  onChanged: (v) => setState(() => _pushNotif = v), 
                  activeThumbColor: AppColors.joyin
                ),
              ),
              const Divider(height: 20, thickness: 1),
              SettingsItem(
                title: 'SMS Notifications',
                subtitle: 'Terima notifikasi penting via SMS',
                trailing: Switch(
                  value: _smsNotif, 
                  onChanged: (v) => setState(() => _smsNotif = v), 
                  activeThumbColor: AppColors.joyin
                ),
              ),
              const Divider(height: 20, thickness: 1),
              SettingsItem(
                title: 'Frekuensi Notifikasi',
                subtitle: '',
                trailing: DropdownButton<String>(
                  value: _notificationFrequency,
                  onChanged: (String? newValue) {
                    setState(() => _notificationFrequency = newValue!);
                  },
                  items: <String>['Real-time', 'Sekali sehari', 'Sekali seminggu']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}