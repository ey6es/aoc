import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(lines.mapToInt(l -> {
        var total = 2 - l.length();
        for (int ii = 0, nn = l.length(); ii < nn; ++ii) {
          var ch = l.charAt(ii);
          total += (ch == '\"' || ch == '\\' ? 2 : 1);
        }
        return total;
      }).sum());
    }
  }
}