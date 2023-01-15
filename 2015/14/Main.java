import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.ArrayList;
import java.util.stream.IntStream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      record Stat(int speed, int flight, int rest) {
        int period () { return flight + rest; }
      }
      var stats = new ArrayList<Stat>();

      lines.forEach(l -> {
        var parts = l.split(" ");
        stats.add(new Stat(Integer.parseInt(parts[3]), Integer.parseInt(parts[6]), Integer.parseInt(parts[13])));
      });

      var duration = 2503;
      var points = new int[stats.size()];
      var distances = new int[stats.size()];
      for (var ii = 0; ii < duration; ++ii) {
        var maxDistance = 0;
        for (var jj = 0; jj < stats.size(); ++jj) {
          var stat = stats.get(jj);
          if (ii % stat.period() < stat.flight()) distances[jj] += stat.speed();
          maxDistance = Math.max(maxDistance, distances[jj]);
        }
        for (var jj = 0; jj < stats.size(); ++jj) {
          if (distances[jj] == maxDistance) points[jj]++;
        }
      }
      System.out.println(IntStream.of(points).max().getAsInt());
    }
  }
}