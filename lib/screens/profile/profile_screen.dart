import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/models/profile_model.dart';
import 'package:compupay_mobile/screens/login/login_screen.dart';
import 'package:compupay_mobile/core/services/profile_service.dart';
import 'package:compupay_mobile/core/widgets/profile_info_card.dart';
import 'package:compupay_mobile/core/widgets/settings_tile.dart';
import 'package:compupay_mobile/screens/notification/notification_screen.dart';
import 'package:compupay_mobile/shared/widgets/app_header.dart';

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      appBar: AppHeader(
        title: 'Profile',
        showBackButton: false,
        backgroundColor: const Color(0xFFF5F5F7),
        foregroundColor: const Color(0xFF6B3EEA),
        titleFontSize: 24,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),

      body: FutureBuilder<ProfileModel>(
        future: ProfileService.getProfile(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(child: Text('Profile tidak ditemukan'));
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                /// PROFILE HEADER
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6B3EEA),
                              width: 4,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.black,
                            backgroundImage:
                                profile.photo != null &&
                                    profile.photo!.isNotEmpty
                                ? NetworkImage(profile.photo!)
                                : null,
                            child: profile.photo == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B3EEA),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      profile.position,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B3EEA),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// PERSONAL INFORMATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3F3D56),
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Edit All',
                        style: TextStyle(
                          color: Color(0xFF6B3EEA),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ProfileInfoCard(
                  title: 'Full Name',
                  value: profile.name,
                  highlighted: true,
                ),

                ProfileInfoCard(
                  title: 'Employee ID (NIK)',
                  value: profile.employeeId,
                ),

                ProfileInfoCard(title: 'Email Address', value: profile.email),

                ProfileInfoCard(title: 'Department', value: profile.department),

                const SizedBox(height: 30),

                /// SETTINGS
                const Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3F3D56),
                  ),
                ),

                const SizedBox(height: 20),

                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance',
                  subtitle: 'Switch between Light and Dark mode',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: const Color(0xFF6B3EEA),
                  ),
                ),

                const SizedBox(height: 14),

                SettingsTile(
                  icon: Icons.notifications_none_rounded,

                  title: 'Notifications',

                  subtitle: 'Payroll status updates and alerts',

                  onTap: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Security',
                  subtitle: 'Biometrics and Password settings',
                  onTap: () {},
                ),

                const SizedBox(height: 36),

                /// LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context),

                    icon: const Icon(Icons.logout, color: Color(0xFFDC2626)),

                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),

                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFDC2626),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    'CompuPay v2.4.0 — Financial Concierge',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
