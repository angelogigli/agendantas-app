import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import 'activity_detail_screen.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  final ApiService _api = ApiService();

  List<WorkshopItem> _workshops = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final result = await _api.getWorkshops(_selectedYear);

      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _workshops = (result['items'] as List?)
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
        title: const Text('Laboratori'),
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
                  '${_workshops.length} laboratori',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildWorkshopsList(),
          ),
        ],
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
}
