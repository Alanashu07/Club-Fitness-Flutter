import 'package:fuzzy/fuzzy.dart';
import 'package:string_similarity/string_similarity.dart';

class SearchService {
  static List<T> fuzzySearch<T>(
    List<T> items,
    String query,
    String Function(T) labelOf, {
    double threshold = 0.4,
    double simCutoff = 0.35,
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return items;

    // ── Build parallel index ───────────────────────
    final List<String> indexTexts = [];
    final List<T> indexItems = [];

    for (final item in items) {
      final label = labelOf(item).toLowerCase().trim();
      if (label.isEmpty) continue;
      indexTexts.add(label);
      indexItems.add(item);
    }

    if (indexTexts.isEmpty) return [];

    // ── Fuzzy filter (typo-tolerant, approximate matching) ─────────────
    final fuse = Fuzzy<String>(
      indexTexts,
      options: FuzzyOptions(threshold: threshold, distance: 100),
    );
    final fuzzyResults = fuse.search(q);
    final fuzzyMatchedIndices = <int>{};
    for (final r in fuzzyResults) {
      final i = indexTexts.indexOf(r.item);
      if (i >= 0) fuzzyMatchedIndices.add(i);
    }

    // ── Score + filter using both fuzzy match and string similarity ────
    final scored = <MapEntry<int, double>>[];

    for (int i = 0; i < indexTexts.length; i++) {
      final label = indexTexts[i];

      double score;
      bool passes;

      if (label == q) {
        score = 1.0;
        passes = true;
      } else if (label.startsWith(q)) {
        score = 0.95;
        passes = true;
      } else if (label.contains(q)) {
        score = 0.85;
        passes = true;
      } else {
        final sim = StringSimilarity.compareTwoStrings(q, label);
        final inFuzzyResults = fuzzyMatchedIndices.contains(i);
        // Only keep items that pass EITHER the fuzzy package's match
        // OR a decent string-similarity score — this is the actual filter.
        passes = inFuzzyResults || sim >= simCutoff;
        // Blend both signals into a single score for ranking.
        score = inFuzzyResults ? (sim * 0.6 + 0.4) : sim;
      }

      if (passes) {
        scored.add(MapEntry(i, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.map((e) => indexItems[e.key]).toList();
  }
}
