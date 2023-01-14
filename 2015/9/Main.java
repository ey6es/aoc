import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.stream.Stream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(new Solver(lines).getLongestDistance());
    }
  }

  static class Solver {
    private final HashMap<String, HashMap<String, Integer>> distances = new HashMap<>();
    private final ArrayList<String> locations;

    public Solver (Stream<String> lines) {
      lines.forEach(l -> {
        var parts = l.split(" ");
        var from = distances.get(parts[0]);
        if (from == null) distances.put(parts[0], from = new HashMap<>());
        var to = distances.get(parts[2]);
        if (to == null) distances.put(parts[2], to = new HashMap<>());
        var distance = Integer.parseInt(parts[4]);
        from.put(parts[2], distance);
        to.put(parts[0], distance);
      });
      locations = new ArrayList<>(distances.keySet());
    }

    public int getLongestDistance () {
      return getLongestDistance(-1, (1 << locations.size()) - 1);
    }

    private int getLongestDistance (int start, int remaining) {
      if (remaining == 0) return 0;
      int maxDistance = 0;
      for (int ii = 0, nn = locations.size(); ii < nn; ++ii) {
        var flag = 1 << ii;
        if ((remaining & flag) != 0) {
          var baseDistance = (start == -1) ? 0 : distances.get(locations.get(start)).get(locations.get(ii));
          maxDistance = Math.max(maxDistance, baseDistance + getLongestDistance(ii, remaining ^ flag));
        }
      }
      return maxDistance;
    }
  }
}