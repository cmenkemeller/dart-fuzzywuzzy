import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/applicable.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';

/// Class for extracting matches from a given list
class Extractor {
  final int _cutoff;

  Extractor([this._cutoff = 0]);

  /// Returns the list of choices with their associated scores of similarity in a list of [ExtractedResult]
  List<ExtractedResult<T>> extractWithoutOrder<T>(
      String query, List<T> choices, Applicable func,
      [String Function(T obj)? getter]) {
    var yields = List<ExtractedResult<T>>.empty(growable: true);
    var index = 0;

    if (T != String) {
      if (getter == null) {
        throw ArgumentError('Getter cannot be null for non-string types!');
      }
    } else {
      getter = (obj) => (obj as String);
    }

    for (var s in choices) {
      var score = func.apply(query.toLowerCase(), getter(s).toLowerCase());

      if (score >= _cutoff) {
        yields.add(ExtractedResult<T>(s, score, index, getter));
      }
      index++;
    }

    return yields;
  }

  /// Returns the list of choices with their associated scores of similarity in a list of [ExtractedResult]
  List<ExtractedResult<T>> extractWithoutOrderMultiFields<T>(
      String query,
      List<T> choices,
      Applicable func,
      List<String Function(T obj)> getters,
      List<int> cutoffs) {
    var yields = List<ExtractedResult<T>>.empty(growable: true);
    var index = 0;

    for (var s in choices) {
      var subScores = List<int>.empty(growable: true);
      for (var i = 0; i < getters.length; i++) {
        final getter = getters[i];
        final queryPhrase = query.toLowerCase();
        final getterPhrase = getter(s).toLowerCase();
        final phraseContains = getterPhrase.contains(queryPhrase);
        var subScore = func.apply(query.toLowerCase(), getter(s).toLowerCase());
        if (subScore > cutoffs[i]) {
          subScore = phraseContains ? 100 : subScore;
          subScores.add(subScore);
        }
      }
      final score = subScores.isEmpty ? 0 : subScores.average;
      if (score >= _cutoff) {
        yields.add(ExtractedResult<T>(s, score.toInt(), index, getters.first));
      }
      index++;
    }
    return yields;
  }

  /// Find the single best match above a score in a list of choices
  ExtractedResult<T> extractOne<T>(
      String query, List<T> choices, Applicable func,
      [String Function(T obj)? getter]) {
    var extracted = extractWithoutOrder(query, choices, func, getter);

    return extracted.reduce(
        (value, element) => value.score > element.score ? value : element);
  }

  /// Creates a **sorted** list of [ExtractedResult] from the most similar choices
  /// to the least.
  List<ExtractedResult<T>> extractSorted<T>(
      String query, List<T> choices, Applicable func,
      [String Function(T obj)? getter]) {
    var best = extractWithoutOrder(query, choices, func, getter)..sort();
    return best.reversed.toList();
  }

  /// Creates a **sorted** list of [ExtractedResult] from the most similar choices
  /// to the least. Allows multiple fields.
  List<ExtractedResult<T>> extractSortedMultiField<T>(
      String query,
      List<T> choices,
      Applicable func,
      List<String Function(T obj)> getters,
      List<int> cutoffs) {
    var best =
        extractWithoutOrderMultiFields(query, choices, func, getters, cutoffs)
          ..sort((a, b) => a.score.compareTo(b.score));
    return best.reversed.toList();
  }

  /// Creates a **sorted** list of [ExtractedResult] which contain the top [limit] most similar choices using k-top heap sort
  List<ExtractedResult<T>> extractTop<T>(
      String query, List<T> choices, Applicable func, int limit,
      [String Function(T obj)? getter]) {
    var best = extractWithoutOrder(query, choices, func, getter);
    var results = _findTopKHeap(best, limit);
    return results.reversed.toList();
  }

  List<ExtractedResult<T>> _findTopKHeap<T>(
      List<ExtractedResult<T>> arr, int k) {
    var pq = PriorityQueue<ExtractedResult<T>>();

    for (var x in arr) {
      if (pq.length < k) {
        pq.add(x);
      } else if (x.compareTo(pq.first) > 0) {
        pq.removeFirst();
        pq.add(x);
      }
    }
    var res = List<ExtractedResult<T>>.empty(growable: true);
    for (var i = k; i > 0; i--) {
      if (pq.isNotEmpty) {
        res.add(pq.removeFirst());
      }
    }
    return res;
  }
}
