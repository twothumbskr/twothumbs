import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../services/profile_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String? _country;
  String? _occupation;
  String _gender = 'm';
  String? _ageBucket;
  bool _needsHalal = false;
  bool _busy = false;
  String? _error;

  bool get _canSubmit =>
      _country != null && _occupation != null && _ageBucket != null;

  Future<void> _save() async {
    if (!_canSubmit) return;
    setState(() { _busy = true; _error = null; });
    try {
      await ProfileService.upsert(
        countryCode: _country!,
        occupation: _occupation!,
        gender: _gender,
        ageBucket: _ageBucket,
        needsHalal: _needsHalal,
      );
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _busy = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tell us about you')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Your ratings will be grouped by country, occupation, and age — so fellow travelers see what matters to them.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // Country
          DropdownButtonFormField<String>(
            initialValue: _country,
            decoration: const InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(),
            ),
            items: popularCountries
                .map((c) => DropdownMenuItem(
                      value: c.code,
                      child: Text('${c.flag}  ${c.name}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _country = v),
          ),
          const SizedBox(height: 16),

          // Occupation
          DropdownButtonFormField<String>(
            initialValue: _occupation,
            decoration: const InputDecoration(
              labelText: 'Occupation',
              border: OutlineInputBorder(),
            ),
            items: occupations
                .map((o) => DropdownMenuItem(value: o.code, child: Text(o.label)))
                .toList(),
            onChanged: (v) => setState(() => _occupation = v),
          ),
          const SizedBox(height: 16),

          // Gender
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'm', label: Text('Male')),
              ButtonSegment(value: 'f', label: Text('Female')),
              ButtonSegment(value: 'x', label: Text('Other')),
            ],
            selected: {_gender},
            onSelectionChanged: (s) => setState(() => _gender = s.first),
          ),
          const SizedBox(height: 16),

          // Age bucket
          DropdownButtonFormField<String>(
            initialValue: _ageBucket,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            items: ageBuckets
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (v) => setState(() => _ageBucket = v),
          ),
          const SizedBox(height: 24),

          // Halal
          SwitchListTile(
            value: _needsHalal,
            onChanged: (v) => setState(() => _needsHalal = v),
            title: const Text('I prefer halal restaurants'),
            subtitle: const Text('We\'ll highlight halal options first'),
            contentPadding: EdgeInsets.zero,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: (_busy || !_canSubmit) ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Start exploring'),
          ),
        ],
      ),
    );
  }
}
