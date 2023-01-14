import java.io.IOException;

import java.nio.file.Files;
import java.nio.file.Path;

import java.util.HashMap;
import java.util.function.Function;
import java.util.function.IntSupplier;

public class Main {
  public static void main (String[] args) throws IOException {
    try (var lines = Files.lines(Path.of("input.txt"))) {
      var suppliers = new HashMap<String, IntSupplier>();
      var cache = new HashMap<String, Integer>();
      Function<String, IntSupplier> getSupplier = s -> {
        try {
          var value = Integer.parseInt(s);
          return () -> value;

        } catch (Exception e) {
          return () -> {
            var result = cache.get(s);
            if (result == null) cache.put(s, result = suppliers.get(s).getAsInt());
            return result;
          };
        }
      };
      lines.forEach(line -> {
        var parts = line.split(" ");
        switch (parts.length) {
          case 3:
            suppliers.put(parts[2], getSupplier.apply(parts[0]));
            break;
          
          case 4: {
            var supplier = getSupplier.apply(parts[1]);
            suppliers.put(parts[3], () -> ~supplier.getAsInt() & 0xFFFF);
            break;
          }

          case 5: {
            var first = getSupplier.apply(parts[0]);
            var second = getSupplier.apply(parts[2]);
            suppliers.put(parts[4], switch (parts[1]) {
              case "RSHIFT" -> () -> (first.getAsInt() >> second.getAsInt()) & 0xFFFF;
              case "LSHIFT" -> () -> (first.getAsInt() << second.getAsInt()) & 0xFFFF;
              case "AND" -> () -> first.getAsInt() & second.getAsInt();
              default -> () -> first.getAsInt() | second.getAsInt();
            });
          }
        }
      });
      var aValue = suppliers.get("a").getAsInt();
      System.out.println(aValue);
      suppliers.put("b", () -> aValue);
      cache.clear();
      System.out.println(suppliers.get("a").getAsInt());
    }
  }
}