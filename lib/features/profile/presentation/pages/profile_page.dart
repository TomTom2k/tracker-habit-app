import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile khi page được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProfileProvider>(context, listen: false).loadProfile();
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await authProvider.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final profile = profileProvider.profile;
    
    final nameController = TextEditingController(text: profile?.fullName ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await profileProvider.updateProfile(
                fullName: nameController.text.trim().isEmpty 
                    ? null 
                    : nameController.text.trim(),
                email: emailController.text.trim().isEmpty 
                    ? null 
                    : emailController.text.trim(),
              );
              
              if (mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(profileProvider.error ?? 'Failed to update profile'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<UserProfileProvider>(context);

    // Lấy thông tin từ auth user (fallback nếu chưa có profile)
    final authUser = authProvider.user;
    final profile = profileProvider.profile;
    
    // Ưu tiên thông tin từ profile, fallback về auth user
    final displayName = profile?.fullName ?? authUser?.name ?? 'User Name';
    final displayEmail = profile?.email ?? authUser?.email ?? 'user@example.com';
    final avatarUrl = profile?.avatarUrl ?? authUser?.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _showEditProfileDialog,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: profileProvider.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => profileProvider.refreshProfile(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        if (profile != null)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                color: Theme.of(context).colorScheme.onPrimary,
                                onPressed: _showEditProfileDialog,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      displayEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ),
                  if (profileProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profileProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: profileProvider.clearError,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ListTile(
                    leading: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    title: Text(
                      themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                    ),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text('Logout'),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
    );
  }
}
