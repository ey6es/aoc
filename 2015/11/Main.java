import java.util.ArrayList;
import java.util.HashMap;

import java.util.function.Supplier;

public class Main {

  public static void main (String[] args) {
    var input = "cqjxxyzz";
    var lettersToIndices = new HashMap<Integer, Byte>();
    var indicesToLetters = new char[23];
    {
      byte index = 0;
      for (var ch = 'a'; ch <= 'z'; ++ch) {
        if (ch != 'i' && ch != 'o' && ch != 'l') {
          indicesToLetters[index] = ch;
          lettersToIndices.put((int)ch, index++);
        }
      }
    }
    var current = new ArrayList<Byte>(input.chars().mapToObj(lettersToIndices::get).toList());
    Supplier<Boolean> isValid = () -> {
      char lastLetter = 0;
      char lastRepeatedLetter = 0;
      var straightLength = 1;
      var hasThreeLetterStraight = false;
      var hasTwoPairs = false;
      for (int ii = 0, nn = current.size(); ii < nn; ++ii) {
        var index = current.get(ii);
        var letter = indicesToLetters[index];
        if (letter == lastLetter + 1) {
          if (++straightLength == 3) hasThreeLetterStraight = true;
        } else {
          straightLength = 1;
          if (letter == lastLetter) {
            if (lastRepeatedLetter != 0 && lastRepeatedLetter != letter) hasTwoPairs = true;
            lastRepeatedLetter = letter;
          }
        }
        lastLetter = letter;
      }
      return hasThreeLetterStraight && hasTwoPairs;
    };
    do {
      var overflow = true;
      for (var ii = current.size() - 1; ii >= 0; --ii) {
        var value = current.get(ii);
        if (value < 22) {
          current.set(ii, (byte)(value + 1));
          overflow = false;
          break;
        }
        current.set(ii, (byte)0);
      }
      if (overflow) current.add(0, (byte)1);
    } while (!isValid.get());
    
    var result = new StringBuilder();
    for (var b : current) result.append(indicesToLetters[b]);
    System.out.println(result);
  }
}