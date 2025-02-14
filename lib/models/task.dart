enum PriorityLevel { Low, Medium, High }

class Task {
  final String title;
  final String description;
  final DateTime dueDate;
  final PriorityLevel priority;
  final bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    PriorityLevel? priority,
    bool? isCompleted,
  }) {
    return Task(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toString(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: PriorityLevel.values.firstWhere(
        (e) => e.toString() == json['priority'],
      ),
      isCompleted: json['isCompleted'],
    );
  }
}
