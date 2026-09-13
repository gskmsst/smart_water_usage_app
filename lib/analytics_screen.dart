import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db_helper.dart';

class AnalyticsScreen extends StatelessWidget {
  final int userId;
  final bool showAppBar;

  const AnalyticsScreen({
    super.key,
    required this.userId,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final bodyContent = FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.fetchDailyTotals(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyanAccent),
          );
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0x220284C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, size: 54, color: Colors.cyanAccent),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Analytics Data Yet',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start tracking your water usage to unlock weekly charts, consumption trends, and smart insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        // Compute metrics
        double totalWeek = 0.0;
        double maxVal = 0.0;
        String peakDate = '';

        for (var item in data) {
          final total = (item['total'] as num).toDouble();
          totalWeek += total;
          if (total > maxVal) {
            maxVal = total;
            peakDate = item['date'] as String? ?? '';
          }
        }

        final double avgDaily = totalWeek / (data.isEmpty ? 1 : data.length);
        final double computedMaxY = (maxVal * 1.25).clamp(10.0, double.infinity);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metric Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      '7-Day Total',
                      '${totalWeek.toStringAsFixed(1)} L',
                      Icons.water_drop,
                      Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Daily Avg',
                      '${avgDaily.toStringAsFixed(1)} L',
                      Icons.speed_rounded,
                      Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bar Chart Card
              Card(
                color: const Color(0x261E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '7-Day Consumption',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Liters (L)',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: computedMaxY,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final rawDate = data[group.x]['date'] as String? ?? '';
                                  final displayDate =
                                      rawDate.length >= 5 ? rawDate.substring(5) : rawDate;
                                  return BarTooltipItem(
                                    '$displayDate\n${rod.toY.toStringAsFixed(1)} L',
                                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0 || value > computedMaxY * 0.95) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= data.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final rawDate = data[index]['date'] as String? ?? '';
                                    final label = rawDate.length >= 10
                                        ? rawDate.substring(5).replaceAll('-', '/')
                                        : rawDate;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: (computedMaxY / 4).clamp(1.0, double.infinity),
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.white.withValues(alpha: 0.07),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: data.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final total = (item['total'] as num).toDouble();
                              final isHighest = total == maxVal && maxVal > 0;

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: total,
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: isHighest
                                          ? [Colors.blue.shade600, Colors.cyanAccent.shade400]
                                          : [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
                                    ),
                                    width: 14,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Peak Day insight
              if (peakDate.isNotEmpty && maxVal > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x1F0284C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.cyanAccent, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Peak usage was ${maxVal.toStringAsFixed(1)} L on $peakDate.',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    if (!showAppBar) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF075985), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(child: bodyContent),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Weekly Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF075985), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(child: bodyContent),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x261E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}