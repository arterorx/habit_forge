import 'package:flutter/material.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _titleCtrl = TextEditingController();
  final _selected = <int>{0, 1, 2, 3, 4}; // по умолчанию будни

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      CreateHabitResult(
        title: title,
        activeWeekdays: _selected.toList()..sort(),
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
                      if (v) {
                        _selected.add(i);
                      } else {
                        _selected.remove(i);
                      }
                    });
                  },
                );
              }),
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
    // 0..6 (пн..вс) — как ты уже выбрал в Domain
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return labels[i];
  }
}

class CreateHabitResult {
  final String title;
  final List<int> activeWeekdays;

  CreateHabitResult({required this.title, required this.activeWeekdays});
}
