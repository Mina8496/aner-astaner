import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:aner_astaner/features/show_all_users_results_page/domain/repositories/results_repository.dart';

class FirestoreResultsRepository implements ResultsRepository {
  @override
  Stream<bool> watchResultsPageEnabled() {
    return FirebaseFirestore.instance
        .collection("settings")
        .doc("resultsPage")
        .snapshots()
        .map((doc) => doc.data()?['enabled'] ?? true);
  }

  @override
  Future<void> setResultsPageEnabled(bool enabled) {
    return FirebaseFirestore.instance
        .collection("settings")
        .doc("resultsPage")
        .set({"enabled": enabled}, SetOptions(merge: true));
  }

  @override
  Future<List<String>> fetchDistinctBookTitles() async {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup("Results")
        .get();

    final titles = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['bookTitle'] is String) {
        titles.add(data['bookTitle']);
      }
    }
    return titles.toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCombinedResults() {
    final resultsStream = FirebaseFirestore.instance
        .collectionGroup("Results")
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return {
              "userId": data['userId'],
              "full_name": data['full_name'] ?? "مستخدم",
              "percentage":
                  double.tryParse(data['percentage']?.toString() ?? "0") ?? 0,
              "score": data['score'] ?? 0,
              "total": data['totalQuestions'] ?? 0,
              "bookTitle": data['bookTitle'] ?? "",
              "chapterTitle": data['chapterTitle'] ?? "",
              "timestamp":
                  (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
              "scoreAyat": null,
              "totalQuestionsAyat": null,
            };
          }).toList(),
        );

    final ayatStream = FirebaseFirestore.instance
        .collection("ExamesAyat")
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            return {
              "userId": data['userId'],
              "full_name": data['full_name'] ?? "مستخدم",
              "percentage": 0.0,
              "score": null,
              "total": null,
              "bookTitle": "",
              "chapterTitle": "",
              "timestamp":
                  (data['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
              "scoreAyat": data['scoreAyat'] ?? 0,
              "totalQuestionsAyat": data['totalQuestionsAyat'] ?? 0,
            };
          }).toList(),
        );

    return Rx.combineLatest2(resultsStream, ayatStream, (a, b) {
      final Map<String, Map<String, dynamic>> merged = {};

      for (var res in a) {
        merged[res['userId']] = res;
      }

      for (var ayat in b) {
        if (merged.containsKey(ayat['userId'])) {
          merged[ayat['userId']]!['scoreAyat'] = ayat['scoreAyat'];
          merged[ayat['userId']]!['totalQuestionsAyat'] =
              ayat['totalQuestionsAyat'];
        } else {
          merged[ayat['userId']] = ayat;
        }
      }

      final combined = merged.values.toList();

      combined.sort((a, b) {
        final aScore = double.tryParse(a['score']?.toString() ?? "0") ?? 0.0;
        final bScore = double.tryParse(b['score']?.toString() ?? "0") ?? 0.0;

        if (bScore.compareTo(aScore) != 0) {
          return bScore.compareTo(aScore);
        }

        final aDate = a['timestamp'] as DateTime;
        final bDate = b['timestamp'] as DateTime;
        return bDate.compareTo(aDate);
      });

      return combined;
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserResults(String userId) {
    return FirebaseFirestore.instance
        .collection('Exames')
        .doc(userId)
        .collection('Results')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}