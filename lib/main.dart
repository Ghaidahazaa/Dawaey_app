// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // تأكد من تهيئة واجهة المستخدم
  await NotificationService().init(); // تهيئة الإشعارات عند تشغيل التطبيق
  runApp(MyApp()); // تشغيل التطبيق
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء الشعار في وضع التصحيح
      title: 'دوائي', // عنوان التطبيق
      theme: ThemeData(
        primarySwatch: Colors.teal, // لون الثيم الأساسي
        fontFamily: 'Tajawal', // تعيين خط التطبيق
      ),
      home: HomePage(), // الصفحة الرئيسية للتطبيق
    );
  }
}







