import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

public class Main {
  public static void main (String[] args) throws IOException {
    var line = Files.readString(Path.of("input.txt"));
    var total = 0;
    for (int ii = 0, nn = line.length(); ii < nn; ++ii) {
      if (line.charAt(ii) == '(') total++;
      else total--;

      if (total == -1) {
        System.out.println(ii + 1);
        break;
      }
    }
  }
}