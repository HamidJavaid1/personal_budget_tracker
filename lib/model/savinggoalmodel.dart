class SavingGoal {
  final int? id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String createdAt;

  SavingGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
  });

  double get progress => targetAmount == 0 ? 0 : savedAmount / targetAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'createdAt': createdAt,
    };
  }

  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
      createdAt: map['createdAt'],
    );
  }
}
