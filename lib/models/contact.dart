class Contact {
  final int id;
  final String nomeclown;
  final String nome;
  final String cognome;
  final String? email;
  final String? telefono;
  final String? foto;

  Contact({
    required this.id,
    required this.nomeclown,
    required this.nome,
    required this.cognome,
    this.email,
    this.telefono,
    this.foto,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? 0,
      nomeclown: json['nomeclown'] ?? '',
      nome: json['nome'] ?? '',
      cognome: json['cognome'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      foto: json['foto'],
    );
  }

  String get fullName => '$nome $cognome';
  String get displayName => nomeclown.isNotEmpty ? nomeclown : fullName;
}
