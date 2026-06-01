import 'dart:io';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/models/profile_model.dart';
import 'package:compupay_mobile/screens/login/login_screen.dart';
import 'package:compupay_mobile/core/services/profile_service.dart';
import 'package:compupay_mobile/core/widgets/profile_info_card.dart';
import 'package:compupay_mobile/core/widgets/settings_tile.dart';
import 'package:compupay_mobile/screens/profile/edit_profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:compupay_mobile/screens/notification/notification_screen.dart';
import 'package:compupay_mobile/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> _logout(BuildContext context) async {
    await SessionService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  late Future<ProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.getProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = ProfileService.getProfile();
    });
  }

  Future<void> _changePhoto(ProfileModel profile) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    try {
      await ProfileService.uploadProfilePhoto(
        userId: profile.id,
        imageFile: File(picked.path),
      );

      _refreshProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Photo updated')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),

            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                _logout(context);
              }
            },
          )
        ],
      ),

      body: FutureBuilder<ProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final profile = snapshot.data;
          print('PHOTO = ${profile?.photo}');

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
                                ? NetworkImage(
                                    '${ApiConfig.baseUrl}/${profile.photo!}',
                                  )
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
                          child: GestureDetector(
                            onTap: () => _changePhoto(profile),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B3EEA),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
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
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(profile: profile),
                          ),
                        );

                        if (updated == true) {
                          _refreshProfile();
                        }
                      },
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

                const SizedBox(height: 36),

                /// LOGOUT BUTTON
                SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),

                  icon: const Icon(
                    Icons.logout,
                    color: Color(0xFFDC2626),
                    size: 20,
                  ),

                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFFDC2626),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
