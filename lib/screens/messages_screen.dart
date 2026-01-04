import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import '../widgets/widgets.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();

  List<Message> _inbox = [];
  List<Message> _sent = [];
  List<Contact> _contacts = [];
  bool _isLoading = true;
  int _unreadCount = 0;

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
      final inbox = await _api.getInbox();
      final sent = await _api.getSentMessages();
      final contacts = await _api.getContacts();
      final unread = await _api.getUnreadCount();

      if (mounted) {
        setState(() {
          _inbox = inbox;
          _sent = sent;
          _contacts = contacts;
          _unreadCount = unread;
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
        title: const Text('Messaggi'),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 20),
              label: const Text('Leggi tutti'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ricevuti'),
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Inviati'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInboxList(),
          _buildSentList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInboxList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_inbox.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox,
        message: 'Nessun messaggio ricevuto',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _inbox.length,
        itemBuilder: (context, index) {
          final message = _inbox[index];
          return _buildMessageTile(message, isInbox: true);
        },
      ),
    );
  }

  Widget _buildSentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sent.isEmpty) {
      return const EmptyState(
        icon: Icons.send,
        message: 'Nessun messaggio inviato',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _sent.length,
        itemBuilder: (context, index) {
          final message = _sent[index];
          return _buildMessageTile(message, isInbox: false);
        },
      ),
    );
  }

  Widget _buildMessageTile(Message message, {required bool isInbox}) {
    final isUnread = isInbox && message.isUnread;

    return Container(
      color: isUnread ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(
                isInbox ? Icons.person : Icons.send,
                color: AppTheme.primaryColor,
              ),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          isInbox ? (message.fromName ?? 'Sconosciuto') : (message.toName ?? 'Destinatario'),
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          message.message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.date,
              style: TextStyle(
                fontSize: 12,
                color: isUnread ? AppTheme.primaryColor : AppTheme.textMuted,
              ),
            ),
          ],
        ),
        onTap: () => _showMessageDetail(message, isInbox: isInbox),
      ),
    );
  }

  void _showMessageDetail(Message message, {required bool isInbox}) {
    // Segna come letto se non letto
    if (isInbox && message.isUnread) {
      _api.markAsRead(message.id).then((_) => _loadData());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    radius: 24,
                    child: const Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isInbox ? 'Da: ${message.fromName}' : 'A: ${message.toName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          message.date,
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
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Message content
              Text(
                message.message,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComposeDialog() {
    final recipientController = TextEditingController();
    final messageController = TextEditingController();
    String? selectedRecipient;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nuovo Messaggio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Destinatario
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Destinatario',
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'RESPONSABILI',
                    child: Text('Responsabili ANTAS'),
                  ),
                  ..._contacts.map((c) => DropdownMenuItem(
                        value: c.id.toString(),
                        child: Text(c.displayName),
                      )),
                ],
                onChanged: (value) {
                  setModalState(() {
                    selectedRecipient = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Messaggio
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Messaggio',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Bottoni
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedRecipient == null || messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compila tutti i campi'),
                              backgroundColor: AppTheme.warningColor,
                            ),
                          );
                          return;
                        }

                        final result = await _api.sendMessage(
                          selectedRecipient!,
                          messageController.text,
                        );

                        Navigator.pop(context);

                        if (result['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Messaggio inviato!'),
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
                      },
                      child: const Text('Invia'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final result = await _api.markAllAsRead();
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tutti i messaggi segnati come letti'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _loadData();
    }
  }
}
