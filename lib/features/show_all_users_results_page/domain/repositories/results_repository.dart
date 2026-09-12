abstract interface class ResultsRepository {
  Stream<bool> watchResultsPageEnabled();

  Future<void> setResultsPageEnabled(bool enabled);

  Future<List<String>> fetchDistinctBookTitles();

  Stream<List<Map<String, dynamic>>> watchCombinedResults();

  Stream<List<Map<String, dynamic>>> watchUserResults(String userId);
}