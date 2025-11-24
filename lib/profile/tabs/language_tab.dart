import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import '../../widgets/settings_item.dart';
import '../../gen_l10n/app_localizations.dart';

class LanguageTab extends StatelessWidget {
  const LanguageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    
    // Safety Check untuk Localization
    String langTitle = "Bahasa";
    String langSubtitle = "Pilih bahasa aplikasi";
    try {
       if (AppLocalizations.of(context) != null) {
         langTitle = AppLocalizations.of(context)!.language;
         langSubtitle = AppLocalizations.of(context)!.chooseLanguage;
       }
    } catch (e) {
      // Fallback
    }

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
                title: langTitle,
                subtitle: langSubtitle,
                trailing: DropdownButton<Locale>(
                  value: provider.locale,
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) provider.setLocale(newLocale);
                  },
                  items: const [
                    DropdownMenuItem(value: Locale('en'), child: Text('English')),
                    DropdownMenuItem(value: Locale('id'), child: Text('Bahasa Indonesia')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}