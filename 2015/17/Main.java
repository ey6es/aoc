import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.stream.Stream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(new Solver(lines).getMinCount());
    }
  }

  static class Solver {
    private int[] sizes;
    private record MinCount(int min, int count) {}

    public Solver (Stream<String> lines) {
      this.sizes = lines.mapToInt(Integer::parseInt).toArray();
    }

    public int getMinCount () {
      return getMinCount(0, 150).count;
    }

    public MinCount getMinCount (int firstIndex, int remainingNog) {
      MinCount minMinCount = null;
      for (var ii = firstIndex; ii < sizes.length; ++ii) {
        var size = sizes[ii];
        if (size > remainingNog) continue;
        var minCount = size == remainingNog
          ? new MinCount(0, 1)
          : getMinCount(ii + 1, remainingNog - size);
        if (minCount != null) {
          minCount = new MinCount(minCount.min + 1, minCount.count);
          if (minMinCount == null || minCount.min < minMinCount.min) minMinCount = minCount;
          else if (minCount.min == minMinCount.min) {
            minMinCount = new MinCount(minCount.min, minCount.count + minMinCount.count);
          }
        }
      }
      return minMinCount;
    }
  }
}