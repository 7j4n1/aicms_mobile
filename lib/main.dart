import 'package:aicms_mobile/screens/dashboard_screen.dart';
import 'package:aicms_mobile/screens/login_screen.dart';
import 'package:aicms_mobile/screens/payment_notification_screen.dart';
import 'package:aicms_mobile/screens/profile_screen.dart';
import 'package:aicms_mobile/screens/records_screen.dart';
import 'package:aicms_mobile/screens/report_download_screen.dart';
import 'package:aicms_mobile/screens/support_ticket_screen.dart';
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/submit-payment': (context) => const PaymentNotificationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/more': (context) => const DashboardScreen(),
        '/records': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          int tabIndex = 0; // default to first tab (savings)

          if (args is Map<String, dynamic> && args.containsKey('tabIndex')) {
            tabIndex = args['tabIndex'];
          }
          return RecordsScreen(initialTabIndex: tabIndex);
        },
        '/reports': (context) => const ReportDownloadScreen(),
        '/settings': (context) => const ReportDownloadScreen(),
        '/support-ticket': (context) => const SupportTicketScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      
    );
  }
}
