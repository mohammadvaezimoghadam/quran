class NotificationPayload {
  final int? id;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final DateTime? sentTime;

  const NotificationPayload({
    this.id,
    this.title,
    this.body,
    this.data = const {},
    this.sentTime,
  });

  @override
  String toString() {
    return 'NotificationPayload(id: $id, title: $title, body: $body, data: $data, sentTime: $sentTime)';
  }
}
