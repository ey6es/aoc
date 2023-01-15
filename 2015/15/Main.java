import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.ArrayList;
import java.util.stream.Stream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(new Solver(lines).getMaxScore());
    }
  }

  static class Solver {
    private ArrayList<int[]> props = new ArrayList<>();

    public Solver (Stream<String> lines) {
      lines.forEach(l -> {
        var parts = l.split(" ");
        var capacity = Integer.parseInt(parts[2].substring(0, parts[2].length() - 1));
        var durability = Integer.parseInt(parts[4].substring(0, parts[4].length() - 1));
        var flavor = Integer.parseInt(parts[6].substring(0, parts[6].length() - 1));
        var texture = Integer.parseInt(parts[8].substring(0, parts[8].length() - 1));
        var calories = Integer.parseInt(parts[10]);
        props.add(new int[] {capacity, durability, flavor, texture, calories});
      });
    }

    public int getMaxScore () {
      return getMaxScore(new ArrayList<>(), 100);
    }

    public int getMaxScore (ArrayList<Integer> amounts, int remaining) {
      if (amounts.size() == props.size()) {
        var factors = new int[5];
        for (int ii = 0, nn = props.size(); ii < nn; ++ii) {
          var amount = amounts.get(ii);
          var prop = props.get(ii);
          for (var jj = 0; jj < 5; ++jj) factors[jj] += amount * prop[jj];
        }
        if (factors[4] != 500) return 0;
        int product = 1;
        for (var jj = 0; jj < 4; ++jj) product *= Math.max(0, factors[jj]);
        return product;
      }
      int maxScore = 0;
      for (var amount = 0; amount <= remaining; amount++) {
        amounts.add(amount);
        maxScore = Math.max(maxScore, getMaxScore(amounts, remaining - amount));
        amounts.remove(amounts.size() - 1);
      }
      return maxScore;
    }
  }
}