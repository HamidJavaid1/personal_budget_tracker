import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Setbudgetgoalsview extends StatefulWidget {
  const Setbudgetgoalsview({super.key, required this.initialGoals});

  final Map<String, double> initialGoals;

  @override
  State<Setbudgetgoalsview> createState() => _SetbudgetgoalsviewState();
}

class _SetbudgetgoalsviewState extends State<Setbudgetgoalsview> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{
      for (final entry in widget.initialGoals.entries)
        entry.key: TextEditingController(text: entry.value.toStringAsFixed(0)),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveGoals() {
    final updated = <String, double>{};

    for (final entry in _controllers.entries) {
      final parsed = double.tryParse(entry.value.text.trim());
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter valid amount for ${entry.key}')),
        );
        return;
      }
      updated[entry.key] = parsed;
    }

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Budget Goals'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: <Widget>[
          TextButton(onPressed: _saveGoals, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Edit your monthly category limits',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA1BCD5) : const Color(0xFF4D689B),
            ),
          ),
          const SizedBox(height: 14),
          ..._controllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: entry.value,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '${entry.key} Goal',
                  prefixIcon: const Icon(Icons.flag_rounded),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saveGoals,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Goals'),
          ),
        ],
      ),
    );
  }
}
