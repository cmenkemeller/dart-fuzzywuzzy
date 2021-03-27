import 'package:fuzzywuzzy/fuzzywuzzy.dart';

void main() {
  // Simple ratio
  print(ratio("mysmilarstring", "myawfullysimilarstirng"));
  print(ratio("mysmilarstring", "mysimilarstring"));

  // Partial ratio
  print(partialRatio("similar", "somewhresimlrbetweenthisstring"));

  // Token sort ratio
  print(tokenSortPartialRatio("order words out of", "words out of order"));
  print(tokenSortRatio("order words out of", "  words out of order"));

  // Token set ratio
  print(tokenSetRatio("fuzzy was a bear", "fuzzy fuzzy fuzzy bear"));
  print(tokenSetPartialRatio("fuzzy was a bear", "fuzzy fuzzy fuzzy bear"));

  // Weighted ratio
  print(weightedRatio("The quick brown fox jimps ofver the small lazy dog",
      "the quick brown fox jumps over the small lazy dog"));
}
