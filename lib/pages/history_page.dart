// lib/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final logs = await DatabaseService().getAdherenceLogs();
    setState(() {
      history = logs;
    });
    print("تم تحميل السجل: $history");
  }

  double get adherenceRate {
    if (history.isEmpty) return 0;
    final takenCount = history.where((log) => log['taken'] == 1).length;
    return takenCount / history.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سجل الالتزام'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'نسبة الالتزام: ${(adherenceRate * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: history.isEmpty
                  ? Center(child: Text('لا يوجد سجل بعد'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final log = history[index];
                        final timeFormatted = DateFormat('yyyy-MM-dd – hh:mm a')
                            .format(DateTime.parse(log['actualTime']));

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(log['name']),
                            subtitle: Text('وقت التناول: $timeFormatted'),
                            trailing: Text(
                              log['taken'] == 1 ? 'تم التناول' : 'تخطي',
                              style: TextStyle(
                                color: log['taken'] == 1 ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}