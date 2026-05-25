import 'package:flutter/material.dart';

import '../../models/employee_profile.dart';
import '../../core/services/profile_service.dart';

import 'widgets/info_card.dart';
import 'widgets/logout_button.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService();

  EmployeeProfile? profile;

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final result = await _service.getProfile();

      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOADING
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ERROR STATE
    if (hasError || profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 70,
                color: Colors.redAccent,
              ),

              const SizedBox(height: 20),

              const Text(
                'Failed to load profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                'Please check your backend connection',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });

                  fetchProfile();
                },

                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // SUCCESS STATE
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              ProfileHeader(profile: profile!),

              const SizedBox(height: 32),

              // PERSONAL INFO TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    'Edit All',
                    style: TextStyle(
                      color: Color(0xFF6C3EF4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // FULL NAME
              InfoCard(title: 'FULL NAME', value: profile!.fullName),

              // EMPLOYEE ID
              InfoCard(title: 'EMPLOYEE ID (NIK)', value: profile!.employeeId),

              // EMAIL
              InfoCard(title: 'EMAIL ADDRESS', value: profile!.email),

              // DEPARTMENT
              InfoCard(title: 'DEPARTMENT', value: profile!.department),

              const SizedBox(height: 30),

              // SETTINGS TITLE
              const Text(
                'App Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // DARK MODE
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Appearance',
                subtitle: 'Switch between Light and Dark mode',

                trailing: Switch(value: true, onChanged: (v) {}),
              ),

              // NOTIFICATION
              SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                subtitle: 'Manage payroll and leave alerts',
              ),

              // SECURITY
              SettingsTile(
                icon: Icons.lock_outline,
                title: 'Security',
                subtitle: 'Biometrics and Password settings',
              ),

              const SizedBox(height: 32),

              // LOGOUT
              LogoutButton(onTap: () {}),

              const SizedBox(height: 30),

              // VERSION
              const Center(
                child: Text(
                  'CompuPay v2.4.0 — Financial Concierge',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
