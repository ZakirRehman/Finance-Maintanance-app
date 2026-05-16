class FinanceModel {
  final String id;
  final String userId;
  final String type; // Income or Expense
  final String? category;
  final double amount;
  final String? description;
  final DateTime date;

  FinanceModel({
    required this.id,
    required this.userId,
    required this.type,
    this.category,
    required this.amount,
    this.description,
    required this.date,
  });

  factory FinanceModel.fromJson(Map<String, dynamic> json) {
    return FinanceModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}

class NoteModel {
  final String id;
  final String userId;
  final String? title;
  final String content;
  final String? colorHex;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    this.colorHex,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      colorHex: json['color_hex'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'color_hex': colorHex,
    };
  }
}

class GoalModel {
  final String id;
  final String userId;
  final String title;
  final DateTime? targetDate;
  final bool isReached;
  final String? category;

  GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    this.targetDate,
    this.isReached = false,
    this.category,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date']) : null,
      isReached: json['is_reached'] ?? false,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target_date': targetDate?.toIso8601String(),
      'is_reached': isReached,
      'category': category,
    };
  }
}
