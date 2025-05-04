// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'add_medication_page.dart';
import 'today_dose_page.dart';
import 'history_page.dart';
import 'adherence_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('دوائي')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('إضافة دواء'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                print("Navigating to Add Medication Page");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddMedicationPage()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.check_circle),
              label: Text('جرعاتي'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                print("Navigating to Adherence Page");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdherencePage()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.today),
              label: Text('جرعات اليوم'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                print("Navigating to Today's Dose Page");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TodayDosePage()),
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.history),
              label: Text('سجل الالتزام'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                print("Navigating to History Page");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}