class Decision {
  String id; // UUID de la décision
  String description;
  DateTime datePrise;
  String? tacheId; // Null si c'est une simple décision, sinon l'ID de la tâche assignée

  Decision({
    required this.id,
    required this.description,
    required this.datePrise,
    this.tacheId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'datePrise': datePrise.toIso8601String(),
      'tacheId': tacheId,
    };
  }

  factory Decision.fromMap(Map<String, dynamic> map) {
    return Decision(
      id: map['id'],
      description: map['description'],
      datePrise: DateTime.parse(map['datePrise']),
      tacheId: map['tacheId'],
    );
  }
}
