import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.BitSet;

public class Main {
  public static void main (String[] args) throws IOException {
    var lines = Files.lines(Path.of("input.txt")).toList();
    var size = 100;
    var bits = new BitSet(size * size);
    for (var row = 0; row < size; ++row) {
      for (var col = 0; col < size; ++col) {
        if (lines.get(row).charAt(col) == '#') bits.set(row * size + col);
      }
    }
    for (var step = 0; step < 100; ++step) {
      var nextBits = new BitSet(size * size);
      for (var row = 0; row < size; ++row) {
        for (var col = 0; col < size; ++col) {
          var neighbors = 0;
          if (row > 0) {
            if (col > 0 && bits.get((row - 1) * size + (col - 1))) neighbors++;
            if (bits.get((row - 1) * size + col)) neighbors++;
            if (col < size - 1 && bits.get((row - 1) * size + (col + 1))) neighbors++;
          }
          if (col > 0 && bits.get(row * size + (col - 1))) neighbors++;
          if (col < size - 1 && bits.get(row * size + (col + 1))) neighbors++;
          if (row < size - 1) {
            if (col > 0 && bits.get((row + 1) * size + (col - 1))) neighbors++;
            if (bits.get((row + 1) * size + col)) neighbors++;
            if (col < size - 1 && bits.get((row + 1) * size + (col + 1))) neighbors++;
          }
          if (neighbors == 3 || bits.get(row * size + col) && neighbors == 2) {
            nextBits.set(row * size + col);
          }
        }
      }
      bits = nextBits;
      bits.set(0);
      bits.set(size - 1);
      bits.set((size - 1) * size);
      bits.set((size - 1) * size + size - 1);
    }
    System.out.println(bits.cardinality());
  }
}