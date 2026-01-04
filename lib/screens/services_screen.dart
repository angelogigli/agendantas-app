import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import 'activity_detail_screen.dart';
import 'workshops_screen.dart';
import 'statistics_screen.dart';
import 'contacts_screen.dart';
import 'rules_screen.dart';
import 'help_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  List<ServiceItem> _services = [];
  List<WorkshopItem> _workshops = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final servicesResult = await _api.getServices(_selectedYear);
      final workshopsResult = await _api.getWorkshops(_selectedYear);

      if (mounted) {
        setState(() {
          if (servicesResult['success'] == true) {
            _services = (servicesResult['items'] as List?)
                    ?.map((s) => ServiceItem.fromJson(s))
                    .toList() ??
                [];
          }
          if (workshopsResult['success'] == true) {
            _workshops = (workshopsResult['items'] as List?)
                    ?.map((w) => WorkshopItem.fromJson(w))
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
        title: const Text('Attivita\''),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'statistics':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                  break;
                case 'contacts':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactsScreen()),
                  );
                  break;
                case 'rules':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RulesScreen()),
                  );
                  break;
                case 'help':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'statistics',
                child: ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('Statistiche'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'contacts',
                child: ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text('Rubrica'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'rules',
                child: ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Regolamento'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help),
                  title: Text('Aiuto'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Servizi'),
            Tab(text: 'Laboratori'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Year selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Anno: '),
                const SizedBox(width: 8),
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
                const Spacer(),
                Text(
                  _tabController.index == 0
                      ? '${_services.length} servizi'
                      : '${_workshops.length} laboratori',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesList(),
                _buildWorkshopsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_services.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        message: 'Nessun servizio trovato',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      service.dataFormatted.split('/')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      _getMonthShort(service.dataFormatted),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(service.categoria),
              subtitle: Text(service.dataFormatted),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActivityDetailScreen(activityId: service.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkshopsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_workshops.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        message: 'Nessun laboratorio trovato',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workshops.length,
        itemBuilder: (context, index) {
          final workshop = _workshops[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.build,
                  color: AppTheme.secondaryColor,
                ),
              ),
              title: Text(workshop.descrizione.isNotEmpty
                  ? workshop.descrizione
                  : workshop.tipo),
              subtitle: Text('${workshop.dataFormatted} - ${workshop.tipo}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActivityDetailScreen(activityId: workshop.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getMonthShort(String date) {
    final months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
                    'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
    try {
      final parts = date.split('/');
      if (parts.length >= 2) {
        final monthIndex = int.parse(parts[1]) - 1;
        return months[monthIndex];
      }
    } catch (_) {}
    return '';
  }
}
