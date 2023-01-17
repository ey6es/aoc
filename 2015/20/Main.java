public class Main {
  public static void main (String[] args) {
    var input = 36000000;
    for (var ii = 1;; ++ii) {
      var presents = 0;
      for (int jj = 1, nn = (int)Math.sqrt(ii); jj <= nn; jj++) {
        if (ii % jj == 0) {
          var factor = ii / jj;
          if (factor <= 50) presents += jj * 11;
          if (factor != jj && jj <= 50) presents += factor * 11;
        }
      }
      if (presents >= input) {
        System.out.println(ii);
        break;
      }
    }
  }
}