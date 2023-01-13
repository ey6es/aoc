import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      final var size = 1000;
      var levels = new int[size][size];
      lines.forEach(line -> {
        var parts = line.split(" ");
        var start = parsePoint(parts[parts.length - 3]);
        var end = parsePoint(parts[parts.length - 1]);
        int offset = switch (parts[1]) {
          case "off" -> -1;
          case "on" -> 1;
          default -> 2;
        };
        for (var yy = start.y; yy <= end.y; ++yy) {
          for (var xx = start.x; xx <= end.x; ++xx) {
            levels[yy][xx] = Math.max(0, levels[yy][xx] + offset);
          }
        }
      });
      int total = 0;
      for (var yy = 0; yy < size; ++yy) {
        for (var xx = 0; xx < size; ++xx) {
          total += levels[yy][xx];
        }
      }
      System.out.println(total);
    }
  }

  record Point(int x, int y) {}

  static Point parsePoint (String pair) {
    var parts = pair.split(",");
    return new Point(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]));
  }
}