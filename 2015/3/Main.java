import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.HashSet;

public class Main {
  
  public static void main (String[] args) throws IOException {
    record Point(int x, int y) {}
    var visited = new HashSet<Point>();
    var points = new Point[] {new Point(0, 0), new Point(0, 0)};
    visited.add(points[0]);

    var line = Files.readString(Path.of("input.txt"));
    for (int ii = 0, nn = line.length(); ii < nn; ++ii) {
      var index = ii % 2;
      var point = points[index];
      points[index] = switch (line.charAt(ii)) {
        case '^' -> new Point(point.x, point.y - 1);
        case 'v' -> new Point(point.x, point.y + 1);
        case '<' -> new Point(point.x - 1, point.y);
        case '>' -> new Point(point.x + 1, point.y);
        default -> point;
      };
      visited.add(points[index]);
    }

    System.out.println(visited.size());
  }
}