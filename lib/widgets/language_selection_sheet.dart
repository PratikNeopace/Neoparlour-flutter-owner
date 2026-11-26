import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neo_parlour_owner/providers/locale_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void showLanguageSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const LanguageSelectionSheet();
    },
  );
}

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentLanguage = localeProvider.locale.languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Language',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildLanguageTile(
            context,
            title: 'English',
            languageCode: 'en',
            currentLanguage: currentLanguage,
            localeProvider: localeProvider,
          ),
          _buildLanguageTile(
            context,
            title: 'हिन्दी',
            languageCode: 'hi',
            currentLanguage: currentLanguage,
            localeProvider: localeProvider,
          ),
          _buildLanguageTile(
            context,
            title: 'मराठी',
            languageCode: 'mr',
            currentLanguage: currentLanguage,
            localeProvider: localeProvider,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String title,
    required String languageCode,
    required String currentLanguage,
    required LocaleProvider localeProvider,
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: currentLanguage == languageCode ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      value: languageCode,
      groupValue: currentLanguage,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (String? value) {
        if (value != null) {
          localeProvider.setLocale(Locale(value));
          Navigator.pop(context);
        }
      },
    );
  }
}
