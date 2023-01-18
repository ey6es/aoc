import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.stream.Stream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(new Solver(lines).getBestScore());
    }
  }

  static class Solver {
    private int[] weights;

    public Solver (Stream<String> lines) {
      weights = lines.mapToInt(Integer::parseInt).toArray();
    }

    public long getBestScore () {
      for (var size = 1;; ++size) {
        var score = getBestScore(0, -1, size);
        if (score != -1) return score;
      }
    }

    private long getBestScore (int flags, int last, int remaining) {
      if (remaining == 0) {
        if (!isValid(flags)) return -1;
        var product = 1L;
        for (var ii = 0; ii < weights.length; ++ii) {
          if ((flags & 1 << ii) != 0) product *= weights[ii];
        }
        return product;
      }
      for (var ii = last + 1; ii < weights.length; ++ii) {
        var score = getBestScore(flags | 1 << ii, ii, remaining - 1);
        if (score != -1) return score;
      }
      return -1;
    }

    private boolean isValid (int flags) {
      var used = 0;
      var remaining = 0;
      for (var ii = 0; ii < weights.length; ++ii) {
        if ((flags & 1 << ii) != 0) used += weights[ii];
        else remaining += weights[ii];
      }
      return remaining == used * 3 && isValid(flags, -1, used, used);
    }

    private boolean isValid (int flags, int last, int remaining, int next) {
      for (var ii = last + 1; ii < weights.length; ++ii) {
        var flag = 1 << ii;
        if ((flags & flag) == 0) {
          var nextRemaining = remaining - weights[ii];
          if (nextRemaining < 0) continue;
          var nextFlags = flags | flag;
          if (nextRemaining == 0 && (next == 0 || isValid(nextFlags, -1, next, 0)) ||
            isValid(nextFlags, ii, nextRemaining, next)) return true;
        }
      }
      return false;
    }
  }
}