import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Main {
  public static void main (String[] args) throws NoSuchAlgorithmException {
    var md5 = MessageDigest.getInstance("md5");
    var input = "yzbqklnj";
    for (var ii = 1;; ++ii) {
      var hash = md5.digest((input + ii).getBytes());
      if (hash[0] == 0 && hash[1] == 0 && hash[2] == 0) {
        System.out.println(ii);
        break;
      }
    }
  }
}