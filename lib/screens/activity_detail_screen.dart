import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class ActivityDetailScreen extends StatefulWidget {
  final int activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _activity;
  List<Participant> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);

    try {
      final result = await _api.getActivityDetail(widget.activityId);

      if (mounted && result['success'] == true) {
        setState(() {
          _activity = result['activity'];
          if (result['partecipanti'] != null) {
            _participants = (result['partecipanti'] as List)
                .map((p) => Participant.fromJson(p))
                .toList();
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
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
        title: Text(_activity?['categoria'] ?? _activity?['tipo'] ?? 'Dettaglio'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activity == null
              ? const Center(child: Text('Attivita\' non trovata'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Data',
                                _activity!['dataFormatted'] ?? '-',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.category,
                                'Tipo',
                                _activity!['tipo'] ?? '-',
                              ),
                              if (_activity!['categoria'] != null &&
                                  _activity!['categoria'].toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  Icons.local_hospital,
                                  'Categoria',
                                  _activity!['categoria'],
                                ),
                              ],
                              if (_activity!['descrizione'] != null &&
                                  _activity!['descrizione'].toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  Icons.description,
                                  'Descrizione',
                                  _activity!['descrizione'],
                                ),
                              ],
                              if (_activity!['note'] != null &&
                                  _activity!['note'].toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  Icons.notes,
                                  'Note',
                                  _activity!['note'],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Partecipanti
                      Row(
                        children: [
                          const Icon(Icons.people, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Partecipanti (${_participants.length}/${_activity!['maxPartecipanti'] ?? 0})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_participants.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Nessun partecipante',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          ),
                        )
                      else
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _participants.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final participant = _participants[index];
                              return ListTile(
                                leading: AvatarImage(
                                  foto: participant.foto,
                                  nomeclown: participant.nomeclown,
                                  size: 40,
                                ),
                                title: Text(participant.nomeclown),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: _activity != null && _activity!['attivo'] != 2
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _activity!['isPrenotato'] == true
                    ? ElevatedButton.icon(
                        onPressed: _unbook,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancella Prenotazione'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _book,
                        icon: const Icon(Icons.check),
                        label: const Text('Prenota'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _book() async {
    final result = await _api.createBooking(widget.activityId);
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prenotazione effettuata!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _loadDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Errore'),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
    }
  }

  Future<void> _unbook() async {
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
      final result = await _api.deleteBooking(widget.activityId);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prenotazione cancellata'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _loadDetail();
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
