import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';

class NotificationTab extends StatelessWidget {
  final String uid;
  const NotificationTab({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final notifService = NotificationService();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active,
                color: AppTheme.accent),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notifService.notificationsStream(uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final bool isRead = data['isRead'] ?? false;
              final Timestamp? ts = data['receivedAt'] as Timestamp?;
              final DateTime? dt = ts?.toDate();
              final String timeStr =
                  dt != null ? timeago.format(dt, allowFromNow: true) : '';

              return GestureDetector(
                onTap: () {
                  if (!isRead) {
                    notifService.markAsRead(uid, docs[i].id);
                  }
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: isRead
                        ? AppTheme.cardBg
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRead
                          ? AppTheme.surfaceLight
                          : AppTheme.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRead
                            ? AppTheme.surfaceLight
                            : AppTheme.accent.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        color:
                            isRead ? AppTheme.textSecondary : AppTheme.accent,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      data['title'] ?? 'SpaceNews Update',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight:
                            isRead ? FontWeight.w400 : FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((data['body'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              data['body'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: isRead
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
