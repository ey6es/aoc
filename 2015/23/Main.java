import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

public class Main {
  public static void main (String[] args) throws IOException {
    var registers = new long[] {1, 0};
    var pc = new int[1];
    var instructions = Files.lines(Path.of("input.txt")).<Runnable>map(l -> {
      var parts = l.split(" ");
      var index = parts[1].charAt(0) - 'a';
      var offset = switch (parts[parts.length - 1].charAt(0)) {
        case '-', '+' -> Integer.parseInt(parts[parts.length - 1]);
        default -> 0;
      };
      switch (parts[0]) {
        case "hlf":
          return () -> { registers[index] /= 2; };

        case "tpl":
          return () -> { registers[index] *= 3; };

        case "inc":
          return () -> { registers[index]++; };

        case "jmp":
          return () -> { pc[0] += offset - 1; };

        case "jie":
          return () -> { if (registers[index] % 2 == 0) pc[0] += offset - 1; };

        default:
        case "jio":
          return () -> { if (registers[index] == 1) pc[0] += offset - 1; };
      }
    }).toList();

    while (pc[0] >= 0 && pc[0] < instructions.size()) {
      instructions.get(pc[0]++).run();
    }

    System.out.println(registers[1]);
  }
}