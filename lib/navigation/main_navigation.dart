import 'package:compupay_mobile/screens/attendance/attendance_screen.dart';
import 'package:compupay_mobile/screens/payslip/payslip_screen.dart';
import 'package:flutter/material.dart';
import 'package:compupay_mobile/navigation/widgets/bottom_navbar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final pages = [
    const Center(child: Text("Home")),
    const AttendanceScreen(),
    const PayslipScreen(),
    const Center(child: Text("Profile")),
  ];

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: SafeArea(
        child: BottomNavBar(currentIndex: currentIndex, onTap: changePage),
      ),
    );
  }
}
