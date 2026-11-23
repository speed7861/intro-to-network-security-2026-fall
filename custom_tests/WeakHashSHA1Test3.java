import java.security.MessageDigest;

public class WeakHashSHA1Test3 {
    public static void main(String[] args) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-1");
        byte[] digest = md.digest("UserTokenData".getBytes());
    }
}
