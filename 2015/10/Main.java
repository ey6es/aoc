

public class Main {

  public static void main (String[] args) {
    var input = "1113222113";
    for (var ii = 0; ii < 50; ++ii) {
      var buffer = new StringBuffer();
      for (int jj = 0, nn = input.length(); jj < nn; ) {
        var ch = input.charAt(jj);
        var length = 1;
        while (++jj < nn && input.charAt(jj) == ch) length++;
        buffer.append(String.valueOf(length));
        buffer.append(ch);
      }
      input = buffer.toString();
    }
    System.out.println(input.length());
  }
}