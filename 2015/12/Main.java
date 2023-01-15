import java.io.IOException;

import java.nio.CharBuffer;
import java.nio.file.Files;
import java.nio.file.Path;

public class Main {
  public static void main (String[] args) throws IOException {
    System.out.println(parseValue(CharBuffer.wrap(Files.readString(Path.of("input.txt")))));
  }

  private static int parseValue (CharBuffer in) {
    var ch = in.get();
    switch (ch) {
      case '[': {
        var total = 0;
        if (in.get() != ']') {
          in.position(in.position() - 1);
          while (true) {
            total += parseValue(in);
            if (in.get() != ',') break;
          }
        }
        return total;
      }
      case '{': {
        var total = 0;
        var ignore = false;
        if (in.get() != '}') {
          in.position(in.position() - 1);
          while (true) {
            parseValue(in);
            in.get();
            if (in.get() == '\"') {
              var start = in.position();
              while (in.get() != '\"');
              if (in.slice(start, in.position() - start - 1).toString().equals("red")) ignore = true;

            } else {
              in.position(in.position() - 1);
              total += parseValue(in);
            }
            if (in.get() != ',') break;
          }
        }
        return ignore ? 0 : total;
      }
      case '\"':
        while (in.get() != '\"');
        return 0;

      default: {
        var builder = new StringBuilder();
        do {
          builder.append(ch);
          ch = in.get();
        } while (ch == '-' || Character.isDigit(ch));
        in.position(in.position() - 1);
        return Integer.parseInt(builder.toString());
      }
    }
  }
}