class User {
  final int id;
  final String username;
  final String nome;
  final String cognome;
  final String nomeclown;
  final String? email;
  final String? telefono;
  final String? foto;
  final int stato;
  final bool regolamentoAccettato;
  final String? dataAccettazioneRegolamento;

  User({
    required this.id,
    required this.username,
    required this.nome,
    required this.cognome,
    required this.nomeclown,
    this.email,
    this.telefono,
    this.foto,
    required this.stato,
    required this.regolamentoAccettato,
    this.dataAccettazioneRegolamento,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nome: json['nome'] ?? '',
      cognome: json['cognome'] ?? '',
      nomeclown: json['nomeclown'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      foto: json['foto'],
      stato: json['stato'] ?? 0,
      regolamentoAccettato: json['regolamentoAccettato'] ?? false,
      dataAccettazioneRegolamento: json['dataAccettazioneRegolamento'],
    );
  }

  String get fullName => '$nome $cognome';

  String get displayName => nomeclown.isNotEmpty ? nomeclown : fullName;
}
