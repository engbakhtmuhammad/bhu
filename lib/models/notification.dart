class NotificationModel {
  final String title;
  final String description;
  final String time;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
  });

  // Factory method to create a NotificationModel from a map (useful for Firestore or APIs)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      time: map['time'] ?? '',
    );
  }

  // Convert NotificationModel to a map (useful for storing in Firestore or local DB)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'time': time,
    };
  }
}
