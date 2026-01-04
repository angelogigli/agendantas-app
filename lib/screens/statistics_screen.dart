import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ApiService _api = ApiService();

  bool _isPersonal = true;
  List<YearStats> _yearStats = [];
  List<MonthStats> _monthStats = [];
  int _selectedYear = DateTime.now().year;
  int _totalGeneral = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final statsResult = _isPersonal
          ? await _api.getPersonalStats()
          : await _api.getGlobalStats();

      final yearlyResult = _isPersonal
          ? await _api.getYearlyStats(_selectedYear)
          : await _api.getGlobalYearlyStats(_selectedYear);

      if (mounted) {
        setState(() {
          if (statsResult['success'] == true) {
            _yearStats = (statsResult['years'] as List?)
                    ?.map((y) => YearStats.fromJson(y))
                    .toList() ??
                [];
            _totalGeneral = statsResult['totaleGenerale'] ?? 0;
          }
          if (yearlyResult['success'] == true) {
            _monthStats = (yearlyResult['months'] as List?)
                    ?.map((m) => MonthStats.fromJson(m))
                    .toList() ??
                [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
        actions: [
          // Toggle personali/globali
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isPersonal = !_isPersonal;
              });
              _loadData();
            },
            icon: Icon(_isPersonal ? Icons.person : Icons.groups),
            label: Text(_isPersonal ? 'Personali' : 'Globali'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Totale generale
                    _buildTotalCard(),
                    const SizedBox(height: 24),

                    // Grafico mensile
                    _buildMonthlyChart(),
                    const SizedBox(height: 24),

                    // Statistiche per anno
                    _buildYearlyStats(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bar_chart,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPersonal ? 'Totale Attivita\'' : 'Totale Globale',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  _totalGeneral.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Andamento Mensile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: List.generate(
                    DateTime.now().year - 2018,
                    (index) => DateTime.now().year - index,
                  )
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (year) {
                    if (year != null) {
                      setState(() {
                        _selectedYear = year;
                      });
                      _loadData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _monthStats.isEmpty
                  ? const Center(child: Text('Nessun dato'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${_monthStats[groupIndex].mese}\n${rod.toY.toInt()}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= 0 && value < _monthStats.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _monthStats[value.toInt()].mese,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: _monthStats.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.totale.toDouble(),
                                color: AppTheme.primaryColor,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
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
    );
  }

  double _getMaxY() {
    if (_monthStats.isEmpty) return 10;
    final max = _monthStats.map((m) => m.totale).reduce((a, b) => a > b ? a : b);
    return (max + 2).toDouble();
  }

  Widget _buildYearlyStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riepilogo Annuale',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (_yearStats.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Nessun dato disponibile'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _yearStats.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final year = _yearStats[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      year.anno.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${year.servizi} servizi, ${year.laboratori} laboratori, ${year.eventi} eventi',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        year.totale.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
