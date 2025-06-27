import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/language_service.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSelectionPage extends StatefulWidget {
  final bool isInitialSetup;
  
  const LanguageSelectionPage({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? selectedLanguage;

  final List<LanguageModel> languages = [
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageModel(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      flag: '🇷🇺',
    ),
    LanguageModel(
      code: 'uz',
      name: 'Uzbek',
      nativeName: 'O\'zbek',
      flag: '🇺🇿',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLanguage = await LanguageService.getLanguage();
    setState(() {
      selectedLanguage = currentLanguage;
    });
  }

  Future<void> _selectLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    setState(() {
      selectedLanguage = languageCode;
    });

    if (widget.isInitialSetup) {
      // Navigate to login page after initial language selection
      AppRouter.pushAndRemoveUntil(context, AppRouter.login);
    } else {
      // Show success message and go back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getLocalizedString('languageChanged', languageCode)),
            backgroundColor: Colors.green,
          ),
        );
        
        // Restart the app to apply language changes
        Future.delayed(const Duration(seconds: 1), () {
          AppRouter.pushAndRemoveUntil(context, AppRouter.splash);
        });
      }
    }
  }

  String _getLocalizedString(String key, String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Язык успешно изменен';
      case 'uz':
        return 'Til muvaffaqiyatli o\'zgartirildi';
      default:
        return 'Language changed successfully';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.isInitialSetup ? null : AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(context),
        ),
        title: Text(l10n.selectLanguage),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isInitialSetup) ...[
                const SizedBox(height: 60),
                
                // App Icon and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _getTitleText(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getSubtitleText(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
              ] else ...[
                const SizedBox(height: 24),
                Text(
                  l10n.choosePreferredLanguage,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
              
              // Language Options
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = selectedLanguage == language.code;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected 
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Text(
                          language.flag,
                          style: const TextStyle(fontSize: 32),
                        ),
                        title: Text(
                          language.nativeName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          language.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        trailing: isSelected 
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : const Icon(Icons.radio_button_unchecked),
                        onTap: () => _selectLanguage(language.code),
                      ),
                    );
                  },
                ),
              ),
              
              if (!widget.isInitialSetup) ...[
                const SizedBox(height: 24),
                Text(
                  'App will restart to apply language changes',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getTitleText() {
    return 'Select Language / Выберите язык / Tilni tanlang';
  }

  String _getSubtitleText() {
    return 'Choose your preferred language to continue / Выберите предпочитаемый язык для продолжения / Davom etish uchun tilni tanlang';
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}