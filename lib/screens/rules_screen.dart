import 'package:flutter/material.dart';
import '../services/services.dart';
import '../utils/theme.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final ApiService _api = ApiService();
  bool _isAccepted = false;
  String? _acceptanceDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    try {
      final user = await _api.getProfile();
      if (mounted && user != null) {
        setState(() {
          _isAccepted = user.regolamentoAccettato;
          _acceptanceDate = user.dataAccettazioneRegolamento;
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
        title: const Text('Regolamento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Status card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isAccepted
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAccepted
                          ? AppTheme.successColor.withOpacity(0.3)
                          : AppTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isAccepted
                              ? AppTheme.successColor.withOpacity(0.2)
                              : AppTheme.warningColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isAccepted ? Icons.check_circle : Icons.warning,
                          color: _isAccepted
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAccepted
                                  ? 'Regolamento Accettato'
                                  : 'Regolamento Non Accettato',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _isAccepted
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                            ),
                            if (_isAccepted && _acceptanceDate != null)
                              Text(
                                'Data accettazione: $_acceptanceDate',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            if (!_isAccepted)
                              Text(
                                'Leggi il regolamento e accettalo',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Regolamento content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Regolamento Clown ANTAS',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildSection(
                              '1. Finalita\'',
                              'L\'associazione ANTAS ha lo scopo di promuovere attivita\' di clownterapia negli ospedali e strutture sanitarie.',
                            ),
                            _buildSection(
                              '2. Partecipazione',
                              'I volontari si impegnano a partecipare regolarmente ai servizi e alle attivita\' formative organizzate dall\'associazione.',
                            ),
                            _buildSection(
                              '3. Comportamento',
                              'Durante i servizi, i clown devono mantenere un comportamento professionale e rispettoso verso pazienti, familiari e personale sanitario.',
                            ),
                            _buildSection(
                              '4. Riservatezza',
                              'I volontari si impegnano a mantenere la massima riservatezza su tutte le informazioni riguardanti i pazienti.',
                            ),
                            _buildSection(
                              '5. Formazione',
                              'E\' obbligatoria la partecipazione ai laboratori formativi organizzati dall\'associazione.',
                            ),
                            _buildSection(
                              '6. Quota Associativa',
                              'I soci devono versare la quota annuale di 35,00 euro. IBAN: IT72R0100503278000000000607 intestato ad ANTAS ONLUS.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: !_isAccepted
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _acceptRules,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Accetta Regolamento'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRules() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accettazione Regolamento'),
        content: const Text(
          'Cliccando su "Accetto" dichiaro di aver letto e accettato il regolamento dell\'Associazione ANTAS - sezione Clownterapia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accetto'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _api.acceptRules();
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regolamento accettato con successo!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _loadStatus();
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
