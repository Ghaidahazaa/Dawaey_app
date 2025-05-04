// lib/pages/today_dose_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../main.dart';

class TodayDosePage extends StatefulWidget {
  @override
  _TodayDosePageState createState() => _TodayDosePageState();
}

class _TodayDosePageState extends State<TodayDosePage> with RouteAware {
  List<Map<String, dynamic>> todayDoses = [];

  @override
  void initState() {
    super.initState();
    _loadTodayDoses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ربط RouteObserver هنا
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // إلغاء الاشتراك عند التخلص من الصفحة
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // أعيد تحميل البيانات عندما تعود لهذه الصفحة
    _loadTodayDoses();
  }

  Future<void> _loadTodayDoses() async {
    final doses = await DatabaseService().fetchTodayDoses();
    setState(() {
      todayDoses = doses;
    });
    print("تم تحميل جرعات اليوم: $todayDoses");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جرعات اليوم'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTodayDoses,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: todayDoses.isEmpty
            ? Center(child: Text('لا توجد جرعات مجدولة لليوم'))
            : ListView.builder(
                itemCount: todayDoses.length,
                itemBuilder: (context, index) {
                  final dose = todayDoses[index];
                  final timeFormatted = DateFormat('hh:mm a')
                      .format(DateTime.parse(dose['time']));

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        dose['taken'] == 1
                            ? Icons.check_circle
                            : Icons.access_time,
                        color:
                            dose['taken'] == 1 ? Colors.green : Colors.orange,
                      ),
                      title: Text('${dose['name']} (${dose['dosage']})'),
                      subtitle: Text('الوقت: $timeFormatted'),
                      trailing: Text(
                        dose['taken'] == 1 ? 'تم التناول' : 'قيد الانتظار',
                        style: TextStyle(
                          color: dose['taken'] == 1
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}