import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _orderUpdates = true;
  bool _promotionalOffers = false;
  bool _darkMode = false;
  String _language = 'English';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFontShowcase(),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 16),
            _buildAppearanceSettings(),
            const SizedBox(height: 16),
            _buildLanguageSettings(),
            const SizedBox(height: 16),
            _buildPrivacySettings(),
            const SizedBox(height: 16),
            _buildSupportSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontShowcase() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poppins Font Showcase',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Light (300)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
            const Text(
              'Regular (400)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            const Text(
              'Medium (500)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const Text(
              'SemiBold (600)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Text(
              'Bold (700)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All text in this app uses the Poppins font family!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Push Notifications',
              'Receive notifications on your device',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            _buildSwitchTile(
              'Email Notifications',
              'Receive notifications via email',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            _buildSwitchTile(
              'SMS Notifications',
              'Receive notifications via SMS',
              _smsNotifications,
              (value) => setState(() => _smsNotifications = value),
            ),
            const Divider(),
            Text(
              'Notification Types',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildSwitchTile(
              'Order Updates',
              'Get notified about order status changes',
              _orderUpdates,
              (value) => setState(() => _orderUpdates = value),
            ),
            _buildSwitchTile(
              'Promotional Offers',
              'Receive offers and discounts',
              _promotionalOffers,
              (value) => setState(() => _promotionalOffers = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme for the app',
              _darkMode,
              (value) {
                setState(() => _darkMode = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dark mode feature coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language & Region',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownTile(
              'Language',
              'Choose your preferred language',
              _language,
              ['English', 'Spanish', 'French', 'German', 'Uzbek'],
              (value) => setState(() => _language = value!),
            ),
            _buildDropdownTile(
              'Currency',
              'Select your currency',
              _currency,
              ['USD', 'EUR', 'GBP', 'UZS'],
              (value) => setState(() => _currency = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy & Security',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              Icons.lock_outline,
              'Change Password',
              'Update your account password',
              () => _showComingSoon('Change Password'),
            ),
            _buildActionTile(
              Icons.fingerprint,
              'Biometric Login',
              'Use fingerprint or face ID to login',
              () => _showComingSoon('Biometric Login'),
            ),
            _buildActionTile(
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              'Read our privacy policy',
              () => _showComingSoon('Privacy Policy'),
            ),
            _buildActionTile(
              Icons.description_outlined,
              'Terms of Service',
              'Read our terms of service',
              () => _showComingSoon('Terms of Service'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support & Feedback',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              Icons.help_outline,
              'Help Center',
              'Get help and support',
              () => _showComingSoon('Help Center'),
            ),
            _buildActionTile(
              Icons.feedback_outlined,
              'Send Feedback',
              'Share your thoughts with us',
              () => _showComingSoon('Send Feedback'),
            ),
            _buildActionTile(
              Icons.star_outline,
              'Rate App',
              'Rate us on the app store',
              () => _showComingSoon('Rate App'),
            ),
            _buildActionTile(
              Icons.info_outline,
              'App Version',
              'Version 1.0.0',
              () => _showVersionInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
      ),
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            Text('Build: 1'),
            Text('Platform: ${Theme.of(context).platform.name}'),
            const SizedBox(height: 16),
            const Text('Delivery Customer App'),
            const Text('Built with Flutter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}