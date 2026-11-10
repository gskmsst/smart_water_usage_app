import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final double dailyGoal;
  final ValueChanged<double> onGoalChanged;
  final bool showGoalAlert;
  final ValueChanged<bool> onShowGoalAlertChanged;
  final bool showDailySummary;
  final ValueChanged<bool> onShowDailySummaryChanged;

  const SettingsScreen({
    super.key,
    required this.dailyGoal,
    required this.onGoalChanged,
    required this.showGoalAlert,
    required this.onShowGoalAlertChanged,
    required this.showDailySummary,
    required this.onShowDailySummaryChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _dailyGoal = widget.dailyGoal.clamp(10.0, 200.0);
  late bool _showGoalAlert = widget.showGoalAlert;
  late bool _showDailySummary = widget.showDailySummary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF075985), Color(0xFF0F172A)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: const Color(0x261E293B),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.tune,
                              color: Colors.cyanAccent,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Daily Consumption Target',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_dailyGoal.toStringAsFixed(0)} L',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _dailyGoal,
                      min: 10,
                      max: 200,
                      divisions: 38,
                      activeColor: Colors.cyanAccent,
                      inactiveColor: Colors.white12,
                      label: '${_dailyGoal.toStringAsFixed(0)} L',
                      onChanged: (value) => setState(() => _dailyGoal = value),
                      onChangeEnd: widget.onGoalChanged,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '10 L (Minimal)',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                        Text(
                          '200 L (High)',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0x261E293B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Alert Preferences',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    key: const ValueKey('goal-alert-setting'),
                    value: _showGoalAlert,
                    activeThumbColor: Colors.cyanAccent,
                    title: const Text(
                      'Daily target alert',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Show your progress toward the daily target on the alerts page.',
                      style: TextStyle(color: Colors.white60),
                    ),
                    onChanged: (value) {
                      setState(() => _showGoalAlert = value);
                      widget.onShowGoalAlertChanged(value);
                    },
                  ),
                  SwitchListTile(
                    key: const ValueKey('daily-summary-setting'),
                    value: _showDailySummary,
                    activeThumbColor: Colors.cyanAccent,
                    title: const Text(
                      'Daily usage summary',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Show a summary card on the alerts page.',
                      style: TextStyle(color: Colors.white60),
                    ),
                    onChanged: (value) {
                      setState(() => _showDailySummary = value);
                      widget.onShowDailySummaryChanged(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
