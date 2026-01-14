import 'package:flutter/material.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _titleCtrl = TextEditingController();
  final _selected = <int>{0, 1, 2, 3, 4}; // будни по умолчанию

  bool _remindersEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      CreateHabitResult(
        title: title,
        activeWeekdays: _selected.toList()..sort(),
        remindersEnabled: _remindersEnabled,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final selected = _selected.contains(i);
                return FilterChip(
                  label: Text(_weekdayLabel(i)),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v ? _selected.add(i) : _selected.remove(i);
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 24),

            SwitchListTile(
              title: const Text('Напоминания'),
              value: _remindersEnabled,
              onChanged: (v) {
                setState(() {
                  _remindersEnabled = v;
                });
              },
            ),

            if (_remindersEnabled)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Время напоминания'),
                subtitle: Text(_reminderTime.format(context)),
                onTap: _pickTime,
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Создать'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(int i) {
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return labels[i];
  }
}

class CreateHabitResult {
  final String title;
  final List<int> activeWeekdays;

  final bool remindersEnabled;
  final int reminderHour;
  final int reminderMinute;

  CreateHabitResult({
    required this.title,
    required this.activeWeekdays,
    required this.remindersEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });
}
