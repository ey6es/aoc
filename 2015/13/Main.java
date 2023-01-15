import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.HashMap;
import java.util.stream.Stream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(new Solver(lines).getMaxHappiness());
    }
  }

  static class Solver {
    private HashMap<Integer, HashMap<Integer, Integer>> diffs = new HashMap<>();

    public Solver (Stream<String> lines) {
      var indices = new HashMap<String, Integer>();
      lines.forEach(l -> {
        var parts = l.split(" ");
        var n0 = parts[0];
        var i0 = indices.get(n0);
        if (i0 == null) indices.put(n0, i0 = indices.size());
        var n1 = parts[10].substring(0, parts[10].length() - 1);
        var i1 = indices.get(n1);
        if (i1 == null) indices.put(n1, i1 = indices.size());
        var diff = diffs.get(i0);
        if (diff == null) diffs.put(i0, diff = new HashMap<>());
        diff.put(i1, Integer.parseInt(parts[3]) * (parts[2].equals("gain") ? 1 : -1));
      });
    }

    public int getMaxHappiness () {
      return getMaxHappiness(0, (1 << diffs.size()) - 2);
    }

    public int getMaxHappiness (int last, int remaining) {
      if (remaining == 0) return diffs.get(last).get(0) + diffs.get(0).get(last);
      var maxHappiness = 0;
      for (int ii = 0, nn = diffs.size(); ii < nn; ++ii) {
        var flag = 1 << ii;
        if ((remaining & flag) != 0) {
          maxHappiness = Math.max(maxHappiness,
            diffs.get(last).get(ii) + diffs.get(ii).get(last) + getMaxHappiness(ii, remaining ^ flag));
        }
      }
      return maxHappiness;
    }
  }
}