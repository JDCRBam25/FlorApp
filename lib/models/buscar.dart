import 'package:cloud_firestore/cloud_firestore.dart';

class SearchHistoryItem {
  final String text;
  final DateTime timestamp;

  SearchHistoryItem({required this.text, required this.timestamp});

  factory SearchHistoryItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SearchHistoryItem(
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
