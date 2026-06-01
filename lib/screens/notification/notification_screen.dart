import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await NotificationService.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = data;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal mengambil notifikasi';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await NotificationService.markAsRead(id);
      await _fetchNotifications();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menandai notifikasi')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      await _fetchNotifications();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menandai semua notifikasi')),
      );
    }
  }

  String _getTitle(Map<String, dynamic> item) {
    return item['title']?.toString() ?? 'Notification';
  }

  String _getBody(Map<String, dynamic> item) {
    return item['body']?.toString() ?? '-';
  }

  String _getType(Map<String, dynamic> item) {
    return item['type']?.toString() ?? 'GENERAL';
  }

  bool _isRead(Map<String, dynamic> item) {
    return item['is_read'] == true;
  }

  Color _getTypeColor(String type) {
    if (type == 'PAYROLL_PAID') {
      return Colors.green;
    }

    if (type == 'PAYROLL_CANCELED') {
      return Colors.red;
    }

    return Colors.deepPurple;
  }

  IconData _getTypeIcon(String type) {
    if (type == 'PAYROLL_PAID') {
      return Icons.check_circle;
    }

    if (type == 'PAYROLL_CANCELED') {
      return Icons.cancel;
    }

    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((item) {
      if (item is! Map) return false;
      return item['is_read'] != true;
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty && unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Read all'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _fetchNotifications,
              child: const Text('Coba lagi'),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 140),
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Belum ada notifikasi',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rawItem = _notifications[index];

        if (rawItem is! Map) {
          return const SizedBox.shrink();
        }

        final item = Map<String, dynamic>.from(rawItem);
        final type = _getType(item);
        final color = _getTypeColor(type);
        final isRead = _isRead(item);

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            final id = item['id']?.toString();

            if (id != null && id.isNotEmpty && !isRead) {
              _markAsRead(id);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? Colors.white : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isRead ? Colors.grey.shade200 : color.withOpacity(0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(_getTypeIcon(type), color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTitle(item),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getBody(item),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        type.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
