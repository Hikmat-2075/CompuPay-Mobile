import 'package:flutter/material.dart';

import 'package:compupay_mobile/navigation/widgets/bottom_navbar.dart';

import 'package:compupay_mobile/screens/attendance/attendance_screen.dart';
import 'package:compupay_mobile/screens/home/home_screen.dart';
import 'package:compupay_mobile/screens/payslip/payslip_screen.dart';
import 'package:compupay_mobile/screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      // HOME
      const Center(
        child: Text(
          "Home",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      // ATTENDANCE
      const AttendanceScreen(),

      // PAYSLIP
      const PayslipScreen(),

      // PROFILE
      const ProfileScreen(),
    ];
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),

      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: changePage,
      ),
    );
  }
}
