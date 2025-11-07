// lib/models/base_utils.dart
DateTime? parseDate(String? s) {
  if (s == null) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

String? formatDate(DateTime? d) => d?.toIso8601String();
