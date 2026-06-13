import 'package:flutter/material.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/core/controllers/home_controller.dart';
import 'package:compupay_mobile/screens/login/login_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onNavigate});

  final ValueChanged<int>? onNavigate;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = HomeController();
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
    controller.init();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  Future<void> handleLogout() async {
    setState(() => isLoggingOut = true);

    await SessionService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  void _goToTab(int index) {
    widget.onNavigate?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    final today = controller.todayAttendance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeCard(
                  name: profile?.name ?? 'Employee',
                  position: profile?.position ?? profile?.role ?? '-',
                  department: profile?.department ?? '-',
                  loading: controller.loading,
                ),
                const SizedBox(height: 22),

                const _SectionTitle(title: 'Today Overview'),
                const SizedBox(height: 12),

                _AttendanceOverviewCard(
                  checkIn: _formatTime(today?.checkIn?.timestamp),
                  checkOut: _formatTime(today?.checkOut?.timestamp),
                  completed: today?.completed == true,
                ),

                if (controller.error != null) ...[
                  const SizedBox(height: 14),
                  _ErrorCard(message: controller.error!),
                ],

                const SizedBox(height: 22),

                const _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.assignment_rounded,
                        title: 'Request',
                        subtitle: 'Buat pengajuan',
                        onTap: () => _goToTab(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Payslip',
                        subtitle: 'Slip gaji',
                        onTap: () => _goToTab(3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                const _SectionTitle(title: 'Announcement'),
                const SizedBox(height: 12),
                const _AnnouncementCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.name,
    required this.position,
    required this.department,
    required this.loading,
  });

  final String name;
  final String position;
  final String department;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3EEA), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3EEA).withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 96,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back 👋',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$position • $department',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

class _AttendanceOverviewCard extends StatelessWidget {
  const _AttendanceOverviewCard({
    required this.checkIn,
    required this.checkOut,
    required this.completed,
  });

  final String checkIn;
  final String checkOut;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _OverviewItem(
                label: 'Check In',
                value: checkIn,
                icon: Icons.login_rounded,
              ),
              const SizedBox(width: 12),
              const _DividerVertical(),
              const SizedBox(width: 12),
              _OverviewItem(
                label: 'Check Out',
                value: checkOut,
                icon: Icons.logout_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFEFFDF5)
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              completed
                  ? 'Attendance completed today'
                  : 'Attendance not completed yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: completed
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFEA580C),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEEE8FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF6B3EEA), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEE8FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF6B3EEA), size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign_outlined, color: Color(0xFF6B3EEA), size: 26),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selamat datang di CompuPay. Gunakan dashboard ini untuk melihat ringkasan aktivitas HR kamu.',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFE11D48),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DividerVertical extends StatelessWidget {
  const _DividerVertical();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xFFE5E7EB));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}
