class Message {
  final int id;
  final int? fromId;
  final int? toId;
  final String? fromName;
  final String? toName;
  final String message;
  final String date;
  final bool read;

  Message({
    required this.id,
    this.fromId,
    this.toId,
    this.fromName,
    this.toName,
    required this.message,
    required this.date,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      fromId: json['fromId'],
      toId: json['toId'],
      fromName: json['fromName'],
      toName: json['toName'],
      message: json['message'] ?? '',
      date: json['date'] ?? '',
      read: json['read'] ?? true,
    );
  }

  bool get isUnread => !read;
}
