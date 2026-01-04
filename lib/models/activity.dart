class Activity {
  final int id;
  final String data;
  final String dataFormatted;
  final int attivo;
  final int maxPartecipanti;
  final String descrizione;
  final String note;
  final String tipo;
  final String categoria;
  final int prenotati;
  final bool isPrenotato;
  final int? tipoId;
  final List<Participant> partecipanti;

  Activity({
    required this.id,
    required this.data,
    required this.dataFormatted,
    required this.attivo,
    required this.maxPartecipanti,
    required this.descrizione,
    required this.note,
    required this.tipo,
    required this.categoria,
    required this.prenotati,
    required this.isPrenotato,
    this.tipoId,
    this.partecipanti = const [],
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    List<Participant> parts = [];
    if (json['partecipanti'] != null) {
      parts = (json['partecipanti'] as List)
          .map((p) => Participant.fromJson(p))
          .toList();
    }

    return Activity(
      id: json['id'] ?? 0,
      data: json['data'] ?? '',
      dataFormatted: json['dataFormatted'] ?? '',
      attivo: json['attivo'] ?? 0,
      maxPartecipanti: json['maxPartecipanti'] ?? 0,
      descrizione: json['descrizione'] ?? '',
      note: json['note'] ?? '',
      tipo: json['tipo'] ?? '',
      categoria: json['categoria'] ?? '',
      prenotati: json['prenotati'] ?? 0,
      isPrenotato: json['isPrenotato'] ?? false,
      tipoId: json['tipoId'],
      partecipanti: parts,
    );
  }

  bool get isClosed => attivo == 2;
  bool get isFull => prenotati >= maxPartecipanti && maxPartecipanti > 0;
}

class Participant {
  final int id;
  final String nomeclown;
  final String? foto;

  Participant({
    required this.id,
    required this.nomeclown,
    this.foto,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] ?? 0,
      nomeclown: json['nomeclown'] ?? '',
      foto: json['foto'],
    );
  }
}

class ServiceItem {
  final int id;
  final String data;
  final String dataFormatted;
  final String categoria;

  ServiceItem({
    required this.id,
    required this.data,
    required this.dataFormatted,
    required this.categoria,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] ?? 0,
      data: json['data'] ?? '',
      dataFormatted: json['dataFormatted'] ?? '',
      categoria: json['categoria'] ?? '',
    );
  }
}

class WorkshopItem {
  final int id;
  final String data;
  final String dataFormatted;
  final String descrizione;
  final String tipo;

  WorkshopItem({
    required this.id,
    required this.data,
    required this.dataFormatted,
    required this.descrizione,
    required this.tipo,
  });

  factory WorkshopItem.fromJson(Map<String, dynamic> json) {
    return WorkshopItem(
      id: json['id'] ?? 0,
      data: json['data'] ?? '',
      dataFormatted: json['dataFormatted'] ?? '',
      descrizione: json['descrizione'] ?? '',
      tipo: json['tipo'] ?? '',
    );
  }
}
