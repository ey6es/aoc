import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.HashMap;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(lines.filter(line -> {
        var repeatsWithCharBetween = false;
        var pairLocations = new HashMap<String, Integer>();
        var repeatedPair = false;
        for (int ii = 0, ll = line.length() - 1; ii <= ll; ++ii) {
          if (ii < ll) {
            var pair = line.substring(ii, ii + 2);
            var location = pairLocations.get(pair);
            if (location == null) pairLocations.put(pair, ii);
            else if (ii - location >= 2) repeatedPair = true;
            if (ii + 1 < ll && line.charAt(ii + 2) == line.charAt(ii)) repeatsWithCharBetween = true;
          }
        }
        return repeatedPair && repeatsWithCharBetween;
      }).count());
    }
  }
}