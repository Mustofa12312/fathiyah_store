class MoneyEngine {
  /// Parses a dynamic value (from JSON/Firestore) to an integer money amount safely.
  /// This handles existing double values gracefully.
  static int parse(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.round();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed.round();
    }
    return 0;
  }
}
