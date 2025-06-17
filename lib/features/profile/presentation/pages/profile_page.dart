import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.push(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'John Doe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'john.doe@example.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, '12', 'Orders'),
                Container(
                  height: 40,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildStatItem(context, '4.8', 'Rating'),
                Container(
                  height: 40,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildStatItem(context, '2', 'Years'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuGroup(
          context,
          'Account',
          [
            _buildMenuItem(
              context,
              Icons.person_outline,
              'Edit Profile',
              'Update your personal information',
              () => _showComingSoon(context, 'Edit Profile'),
            ),
            _buildMenuItem(
              context,
              Icons.location_on_outlined,
              'Addresses',
              'Manage your delivery addresses',
              () => AppRouter.push(context, AppRouter.addresses),
            ),
            _buildMenuItem(
              context,
              Icons.payment_outlined,
              'Payment Methods',
              'Manage your payment options',
              () => _showComingSoon(context, 'Payment Methods'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          context,
          'Orders',
          [
            _buildMenuItem(
              context,
              Icons.receipt_long_outlined,
              'Order History',
              'View your past orders',
              () => _showComingSoon(context, 'Order History'),
            ),
            _buildMenuItem(
              context,
              Icons.favorite_outline,
              'Favorites',
              'Your favorite restaurants and dishes',
              () => _showComingSoon(context, 'Favorites'),
            ),
            _buildMenuItem(
              context,
              Icons.star_outline,
              'Reviews',
              'Your reviews and ratings',
              () => _showComingSoon(context, 'Reviews'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          context,
          'Support',
          [
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Help Center',
              'Get help and support',
              () => _showComingSoon(context, 'Help Center'),
            ),
            _buildMenuItem(
              context,
              Icons.chat_outlined,
              'Contact Us',
              'Reach out to our support team',
              () => _showComingSoon(context, 'Contact Us'),
            ),
            _buildMenuItem(
              context,
              Icons.info_outline,
              'About',
              'App information and version',
              () => _showAboutDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGroup(
          context,
          'Account Actions',
          [
            _buildMenuItem(
              context,
              Icons.logout,
              'Logout',
              'Sign out of your account',
              () => _showLogoutDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup(BuildContext context, String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive 
            ? Colors.red 
            : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
              ? Colors.red 
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Delivery Customer',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delivery_dining,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'A modern food delivery app built with Flutter. Order your favorite meals from local restaurants with fast and reliable delivery.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
              AppRouter.pushAndRemoveUntil(context, AppRouter.login);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}