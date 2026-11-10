import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  final double todayUsage;
  final double dailyGoal;
  final bool showGoalAlert;
  final bool showDailySummary;

  const AlertsScreen({
    super.key,
    required this.todayUsage,
    required this.dailyGoal,
    required this.showGoalAlert,
    required this.showDailySummary,
  });

  @override
  Widget build(BuildContext context) {
    final goalReached = todayUsage >= dailyGoal;
    final progress = dailyGoal > 0
        ? (todayUsage / dailyGoal).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
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
            if (showGoalAlert)
              Card(
                color: const Color(0x261E293B),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        goalReached
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: goalReached
                            ? Colors.amberAccent
                            : Colors.cyanAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goalReached
                                  ? 'Daily target reached'
                                  : 'You’re within your daily target',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${todayUsage.toStringAsFixed(1)} L used of your ${dailyGoal.toStringAsFixed(0)} L daily target.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  goalReached
                                      ? Colors.amberAccent
                                      : Colors.cyanAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (showGoalAlert && showDailySummary) const SizedBox(height: 12),
            if (showDailySummary)
              Card(
                color: const Color(0x261E293B),
                child: const ListTile(
                  leading: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.cyanAccent,
                  ),
                  title: Text(
                    'Daily usage summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Your daily water usage status is shown here.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              ),
            if (!showGoalAlert && !showDailySummary)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: Text(
                    'Alerts are turned off. You can enable them in Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
