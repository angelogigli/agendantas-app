import 'package:flutter/material.dart';
import '../utils/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aiuto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpSection(
              icon: Icons.home,
              title: 'Dashboard',
              items: [
                'Visualizza le statistiche personali dell\'anno corrente',
                'Consulta i prossimi servizi e laboratori',
                'Prenota o cancella la partecipazione alle attivita\'',
              ],
            ),
            _buildHelpSection(
              icon: Icons.people,
              title: 'Servizi',
              items: [
                'Visualizza lo storico dei servizi effettuati',
                'Filtra per anno',
                'Tocca un servizio per vedere i dettagli e i partecipanti',
              ],
            ),
            _buildHelpSection(
              icon: Icons.build,
              title: 'Laboratori',
              items: [
                'Visualizza lo storico dei laboratori e eventi',
                'I laboratori formativi sono obbligatori per i soci',
              ],
            ),
            _buildHelpSection(
              icon: Icons.mail,
              title: 'Messaggi',
              items: [
                'Invia messaggi agli altri clown o ai responsabili',
                'I messaggi non letti sono evidenziati con un pallino blu',
                'Tocca "Leggi tutti" per segnare tutti come letti',
              ],
            ),
            _buildHelpSection(
              icon: Icons.contacts,
              title: 'Rubrica',
              items: [
                'Cerca i contatti degli altri clown',
                'Chiama, invia email o messaggi direttamente',
              ],
            ),
            _buildHelpSection(
              icon: Icons.bar_chart,
              title: 'Statistiche',
              items: [
                'Visualizza le statistiche personali o globali',
                'Consulta l\'andamento mensile con i grafici',
                'Confronta i dati tra anni diversi',
              ],
            ),
            _buildHelpSection(
              icon: Icons.description,
              title: 'Regolamento',
              items: [
                'Leggi il regolamento dell\'associazione',
                'Accetta il regolamento per completare l\'iscrizione',
              ],
            ),
            _buildHelpSection(
              icon: Icons.person,
              title: 'Profilo',
              items: [
                'Modifica i tuoi dati personali (email, telefono)',
                'Cambia la password',
                'Esci dall\'applicazione',
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: AppTheme.infoColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppTheme.infoColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hai bisogno di assistenza?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contatta i responsabili ANTAS tramite la sezione Messaggi.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
