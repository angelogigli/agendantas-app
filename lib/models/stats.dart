class DashboardStats {
  final int servizi;
  final int laboratori;
  final int eventi;

  DashboardStats({
    required this.servizi,
    required this.laboratori,
    required this.eventi,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      servizi: json['servizi'] ?? 0,
      laboratori: json['laboratori'] ?? 0,
      eventi: json['eventi'] ?? 0,
    );
  }

  int get total => servizi + laboratori + eventi;
}

class YearStats {
  final int anno;
  final int totale;
  final int servizi;
  final int laboratori;
  final int eventi;

  YearStats({
    required this.anno,
    required this.totale,
    required this.servizi,
    required this.laboratori,
    required this.eventi,
  });

  factory YearStats.fromJson(Map<String, dynamic> json) {
    return YearStats(
      anno: json['anno'] ?? 0,
      totale: json['totale'] ?? 0,
      servizi: json['servizi'] ?? 0,
      laboratori: json['laboratori'] ?? 0,
      eventi: json['eventi'] ?? 0,
    );
  }
}

class MonthStats {
  final String mese;
  final int totale;

  MonthStats({
    required this.mese,
    required this.totale,
  });

  factory MonthStats.fromJson(Map<String, dynamic> json) {
    return MonthStats(
      mese: json['mese'] ?? '',
      totale: json['totale'] ?? 0,
    );
  }
}
