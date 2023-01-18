import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

public class Main {
  public static void main (String[] args) throws IOException {
    var input = Files.readString(Path.of("input.txt")).trim();
    var parts = input.split(" ");
    var targetRow = Integer.parseInt(parts[16].substring(0, parts[16].length() - 1));
    var targetCol = Integer.parseInt(parts[18].substring(0, parts[18].length() - 1));

    var value = 20151125L;
    for (var diagonalLength = 1;; ++diagonalLength) {
      var row = diagonalLength;
      var col = 1;
      for (var ii = 0; ii < diagonalLength; ++ii, --row, ++col) {
        if (row == targetRow && col == targetCol) {
          System.out.println(value);
          return;
        }
        value = value * 252533L % 33554393L;
      }
    }
  }
}