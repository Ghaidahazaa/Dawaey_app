import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AddMedicationPage extends StatefulWidget {
  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _dosesPerDayController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  TimeOfDay? _firstDoseTime;
  String _frequency = 'daily';
  List<int> _selectedDays = [];
  bool _isPermanent = false;

  final List<String> _frequencies = ['daily', 'weekly', 'monthly'];
  final List<String> _weekDays = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _firstDoseTime = picked);
    }
  }

  void _toggleDaySelection(int index) {
    setState(() {
      final day = index + 1;
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة دواء')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'اسم الدواء'),
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'الجرعة'),
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _dosesPerDayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'عدد الجرعات باليوم'),
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'الفاصل بين الجرعات (بالساعات)'),
              ),
              ListTile(
                title: Text(_firstDoseTime == null
                    ? 'اختر وقت أول جرعة'
                    : 'أول جرعة: ${_firstDoseTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              DropdownButtonFormField(
                value: _frequency,
                items: _frequencies.map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f == 'daily' ? 'يومي' : f == 'weekly' ? 'أسبوعي' : 'شهري'),
                )).toList(),
                onChanged: (val) => setState(() => _frequency = val as String),
                decoration: InputDecoration(labelText: 'التكرار'),
              ),
              if (_frequency != 'daily')
                Wrap(
                  spacing: 8,
                  children: List.generate(_weekDays.length, (index) {
                    return FilterChip(
                      label: Text(_weekDays[index]),
                      selected: _selectedDays.contains(index + 1),
                      onSelected: (_) => _toggleDaySelection(index),
                    );
                  }),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'عدد الأيام'),
                      enabled: !_isPermanent,
                      validator: (value) =>
                          !_isPermanent && (value == null || value.isEmpty) ? 'مطلوب' : null,
                    ),
                  ),
                  Checkbox(
                    value: _isPermanent,
                    onChanged: (val) => setState(() => _isPermanent = val ?? false),
                  ),
                  const SizedBox(width: 8),
                  const Text('دائم'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _firstDoseTime != null) {
                    final now = DateTime.now();
                    final firstDoseDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _firstDoseTime!.hour,
                      _firstDoseTime!.minute,
                    );

                    final med = Medication(
                      name: _nameController.text,
                      dosage: _dosageController.text,
                      dosesPerDay: int.parse(_dosesPerDayController.text),
                      firstDoseTime: firstDoseDateTime,
                      frequency: _frequency,
                      selectedDays: _selectedDays,
                      durationInDays: int.tryParse(_durationController.text) ?? 0,
                      isPermanent: _isPermanent,
                      intervalHours: int.tryParse(_intervalController.text),
                    );

                    try {
                      await DatabaseService().insertMedication(med);
                      print("تم إضافة الدواء: ${med.name}");
                      await NotificationService().scheduleMedication(
                        name: med.name,
                        dosage: med.dosage,
                        firstDose: med.firstDoseTime,
                        dosesPerDay: med.dosesPerDay,
                        durationInDays: med.durationInDays,
                        isPermanent: med.isPermanent,
                        intervalHours: med.intervalHours ?? 0,
                        frequency: med.frequency,
                        selectedDays: med.selectedDays,
                      );
                      print("تم جدولة الإشعارات للدواء: ${med.name}");
                    } catch (e) {
                      print("حدث خطأ أثناء الحفظ أو الجدولة: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('حدث خطأ، يرجى المحاولة لاحقًا')),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ الدواء وجدولة التذكير')),
                    );

                    Navigator.pop(context);
                  } else if (_firstDoseTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى اختيار وقت أول جرعة')),
                    );
                  }
                },
                child: const Text('حفظ وبدء التذكير'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

