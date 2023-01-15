import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.Map;
import java.util.function.IntPredicate;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      var props = Map.<String, IntPredicate>of(
        "children", v -> v == 3, "cats", v -> v > 7, "samoyeds", v -> v == 2, "pomeranians", v -> v < 3,
        "akitas", v -> v == 0, "vizslas", v -> v == 0, "goldfish", v -> v < 5, "trees", v -> v > 3,
        "cars", v -> v == 2, "perfumes", v -> v == 1);
      lines.forEach(l -> {
        var parts = l.split(" ");
        var k0 = parts[2].substring(0, parts[2].length() - 1);
        var v0 = Integer.parseInt(parts[3].substring(0, parts[3].length() - 1));
        var k1 = parts[4].substring(0, parts[4].length() - 1);
        var v1 = Integer.parseInt(parts[5].substring(0, parts[5].length() - 1));
        var k2 = parts[6].substring(0, parts[6].length() - 1);
        var v2 = Integer.parseInt(parts[7]);
        if (props.get(k0).test(v0) && props.get(k1).test(v1) && props.get(k2).test(v2)) {
          System.out.println(parts[1].substring(0, parts[1].length() - 1));
        }
      });
    }
  }
}