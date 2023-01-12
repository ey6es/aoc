import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.stream.IntStream;
import java.util.stream.Stream;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      System.out.println(lines.mapToInt(s -> {
        var parts = Stream.of(s.split("x")).mapToInt(Integer::parseInt).toArray();
        var perims = new int[] {parts[0] * 2 + parts[1] * 2, parts[1] * 2 + parts[2] * 2, parts[2] * 2 + parts[0] * 2};
        return IntStream.of(perims).min().orElseThrow() + parts[0] * parts[1] * parts[2];
      }).sum());
    }
  }
}