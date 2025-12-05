import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../reminders/screens/reminders_screen.dart';
import 'edit_profile_screen.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          profileImagePath: image.path,
        );
        await authProvider.updateProfile(updatedUser);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDarkBlue, AppTheme.darkBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;

            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 80, color: AppTheme.textSecondary),
                    const SizedBox(height: 16),
                    const Text('No user logged in', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18)),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    centerTitle: true,
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryDarkBlue, AppTheme.primaryBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Profile Image - Clickable
                        GestureDetector(
                          onTap: () => _pickImage(context),
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [AppTheme.accentBlue, AppTheme.primaryBlue],
                                  ),
                                  border: Border.all(color: AppTheme.accentBlue, width: 3),
                                ),
                                child: ClipOval(
                                  child: user.profileImagePath != null && user.profileImagePath!.isNotEmpty
                                      ? Image.file(
                                          File(user.profileImagePath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.person, size: 60, color: Colors.white);
                                          },
                                        )
                                      : const Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.darkBackground, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),

                        // Profile Details Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildInfoRow(Icons.cake, 'Age', '${user.age} years'),
                                const Divider(height: 24),
                                _buildInfoRow(Icons.wc, 'Gender', user.gender ?? 'Not set'),
                                const Divider(height: 24),
                                _buildInfoRow(Icons.height, 'Height', user.height > 0 ? '${user.height} cm' : 'Not set'),
                                const Divider(height: 24),
                                _buildInfoRow(Icons.monitor_weight, 'Weight', user.weight > 0 ? '${user.weight} kg' : 'Not set'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Reminders Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RemindersScreen()),
                              );
                            },
                            icon: const Icon(Icons.notifications, color: AppTheme.accentBlue),
                            label: const Text('Health Reminders', style: TextStyle(fontSize: 16, color: AppTheme.accentBlue)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.accentBlue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Edit Profile Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                              );
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text('Edit Profile', style: TextStyle(fontSize: 16, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await authProvider.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                            label: const Text('Logout', style: TextStyle(fontSize: 16, color: AppTheme.errorColor)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.errorColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentBlue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
