import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/parent_preferences.dart';

/// A display preference, not a security gate or a deletion control.
class ParentGoalSetting extends StatefulWidget {
  const ParentGoalSetting({super.key});
  @override
  State<ParentGoalSetting> createState() => _ParentGoalSettingState();
}

class _ParentGoalSettingState extends State<ParentGoalSetting> {
  bool _saving = false;
  bool _failed = false;
  bool? _attempted;
  @override
  void initState() { super.initState(); unawaited(_restore()); }
  Future<void> _restore() async {
    try { await ParentPreferences.instance.restore(); if (mounted) setState(() => _failed = false); }
    catch (_) { if (mounted) setState(() => _failed = true); }
  }
  Future<void> _set(bool value) async {
    setState(() { _saving = true; _failed = false; _attempted = value; });
    final ok = await ParentPreferences.instance.setShowGoals(value);
    if (!mounted) return;
    setState(() { _saving = false; _failed = !ok; });
  }
  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    return ListenableBuilder(listenable: ParentPreferences.instance, builder: (context, _) {
      final store = ParentPreferences.instance;
      return Column(children: <Widget>[
        SwitchListTile(
          key: const ValueKey('parent-show-goals'),
          value: store.showGoals,
          onChanged: store.isLoaded && !_saving ? _set : null,
          title: Text(sw ? 'Onyesha malengo Nyumbani' : 'Show goals on Home'),
          subtitle: Text(sw
              ? 'Ficha au onyesha kalenda, mfululizo na nyota Nyumbani. Shughuli bado huhifadhiwa kwenye kifaa.'
              : 'Show or hide the calendar, streak and stars on Home. Activity is still saved on this device.'),
        ),
        if (_failed) TextButton(onPressed: () => _attempted == null ? _restore() : _set(_attempted!),
          child: Text(sw ? 'Haikuhifadhiwa. Jaribu tena' : 'Not saved. Try again')),
      ]);
    });
  }
}
