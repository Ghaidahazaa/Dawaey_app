import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdherencePage extends StatefulWidget {
  @override
  _AdherencePageState createState() => _AdherencePageState();
}

class _AdherencePageState extends State<AdherencePage> {
  List<Map<String, dynamic>> doses = [];

  @override
  void initState() {
    super.initState();
    _loadDoses();
  }

  Future<void> _loadDoses() async {
    final fetchedDoses = await DatabaseService().fetchTodayDoses();
    setState(() {
      doses = fetchedDoses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جرعاتي'),
      ),
      body: ListView.builder(
        itemCount: doses.length,
        itemBuilder: (context, index) {
          final dose = doses[index];
          return ListTile(
            title: Text(dose['name']),
            subtitle: Text('الجرعة: ${dose['dosage']}'),
            trailing: Text(dose['status']),
          );
        },
      ),
    );
  }
}
