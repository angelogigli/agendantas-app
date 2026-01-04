import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';
import 'activity_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  DashboardStats? _stats;
  List<Activity> _services = [];
  List<Activity> _workshops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await _api.getStats();
      final upcoming = await _api.getUpcomingActivities();

      if (mounted) {
        setState(() {
          _stats = stats;
          if (upcoming['success'] == true) {
            _services = (upcoming['services'] as List?)
                    ?.map((s) => Activity.fromJson(s))
                    .toList() ??
                [];
            _workshops = (upcoming['workshops'] as List?)
                    ?.map((w) => Activity.fromJson(w))
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
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            if (user != null)
              Text(
                'Ciao, ${user.displayName}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    _buildStatsCards(),
                    const SizedBox(height: 24),

                    // Prossimi Servizi
                    _buildSectionTitle('Prossimi Servizi', Icons.people),
                    const SizedBox(height: 12),
                    _buildServicesList(),
                    const SizedBox(height: 24),

                    // Prossimi Laboratori/Eventi
                    _buildSectionTitle('Laboratori / Eventi', Icons.build),
                    const SizedBox(height: 12),
                    _buildWorkshopsList(),
                    const SizedBox(height: 32),

                    // Versione app
                    Center(
                      child: Text(
                        'AgendANTAS v1.1.3',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.people,
            iconColor: AppTheme.primaryColor,
            value: _stats?.servizi.toString() ?? '0',
            label: 'Servizi',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.build,
            iconColor: AppTheme.secondaryColor,
            value: _stats?.laboratori.toString() ?? '0',
            label: 'Laboratori',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.star,
            iconColor: AppTheme.successColor,
            value: _stats?.eventi.toString() ?? '0',
            label: 'Eventi',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    if (_services.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        message: 'Nessun servizio in programma',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length > 5 ? 5 : _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return ActivityCard(
          activity: service,
          onTap: () => _openDetail(service),
          onBook: () => _bookActivity(service),
          onUnbook: () => _unbookActivity(service),
        );
      },
    );
  }

  Widget _buildWorkshopsList() {
    if (_workshops.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        message: 'Nessun laboratorio/evento in programma',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _workshops.length > 5 ? 5 : _workshops.length,
      itemBuilder: (context, index) {
        final workshop = _workshops[index];
        return ActivityCard(
          activity: workshop,
          isWorkshop: true,
          onTap: () => _openDetail(workshop),
          onBook: () => _bookActivity(workshop),
          onUnbook: () => _unbookActivity(workshop),
        );
      },
    );
  }

  void _openDetail(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDetailScreen(activityId: activity.id),
      ),
    );
  }

  Future<void> _bookActivity(Activity activity) async {
    final result = await _api.createBooking(activity.id);
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prenotazione effettuata!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Errore'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  Future<void> _unbookActivity(Activity activity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma'),
        content: const Text('Vuoi cancellare la prenotazione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            child: const Text('Cancella'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _api.deleteBooking(activity.id);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prenotazione cancellata'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Errore'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }
}
