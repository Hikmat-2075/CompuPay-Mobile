import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _purple = Color(0xFF6C4AF2);
  static const Color _bg = Color(0xFFF6F7FB);

  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _timeText(DateTime dt) => "${_two(dt.hour)}:${_two(dt.minute)}";

  String _weekday(int w) {
    switch (w) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      default:
        return "Sunday";
    }
  }

  String _monthShort(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }

  String _dateText(DateTime dt) =>
      "${_weekday(dt.weekday)}, ${_two(dt.day)} ${_monthShort(dt.month)} ${dt.year}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: _purple.withOpacity(.15),
            child: const Icon(Icons.person, color: _purple),
          ),
        ),
        title: const Text(
          "CompuPay",
          style: TextStyle(
            color: _purple,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _purple,
        unselectedItemColor: const Color(0xFFB7BAC7),
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "HOME"),
          BottomNavigationBarItem(icon: Icon(Icons.event_available_rounded), label: "ATTENDANCE"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "PAYSLIP"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "PROFILE"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _GreetingSection(
                title: "Halo, John Employee",
                subtitle: "Software Engineer",
              ),
              const SizedBox(height: 16),

              _Card(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(
                      "CURRENT TIME",
                      style: TextStyle(
                        color: Colors.black.withOpacity(.45),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _timeText(_now),
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dateText(_now),
                      style: TextStyle(
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _Card(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _PrimaryButton(
                      icon: Icons.login_rounded,
                      text: "Check In",
                      onPressed: () {},
                    ),
                    const SizedBox(height: 10),
                    _SecondaryButton(
                      icon: Icons.logout_rounded,
                      text: "Check Out",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ESTIMATED TAKE HOME PAY",
                      style: TextStyle(
                        color: Colors.black.withOpacity(.45),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Rp 12.450.000",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _purple.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.show_chart_rounded, color: _purple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.72,
                        minHeight: 6,
                        backgroundColor: Colors.black.withOpacity(.07),
                        valueColor: const AlwaysStoppedAnimation(_purple),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Next pay cycle is in 7 days",
                      style: TextStyle(
                        color: Colors.black.withOpacity(.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Recent Notifications",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See All",
                      style: TextStyle(color: _purple, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const _NotificationTile(
                icon: Icons.account_balance_wallet_rounded,
                iconBg: Color(0xFFEDEAFF),
                iconColor: _purple,
                title: "Gaji bulan Desember telah tersedia",
                subtitle: "Your payslip for the month of December is ready for review.",
                timeLabel: "2 HOURS AGO",
              ),
              const SizedBox(height: 12),
              const _NotificationTile(
                icon: Icons.calendar_month_rounded,
                iconBg: Color(0xFFFFF2DD),
                iconColor: Color(0xFFB9771A),
                title: "Pengumuman Cuti Bersama",
                subtitle:
                    "Updates regarding the collective leave schedule for year-end holidays.",
                timeLabel: "YESTERDAY",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _GreetingSection({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.black.withOpacity(.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // <-- TAMBAH INI (biar semua card sama lebar)
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  static const Color _purple = Color(0xFF6C4AF2);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEEF2),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeLabel;

  const _NotificationTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.55),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.35),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}