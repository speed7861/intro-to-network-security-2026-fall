import java.security.MessageDigest;

public class WeakHashMD5Test2 {
    public static void main(String[] args) throws Exception {
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] digest = md.digest("SensitivePassword123".getBytes());
    }
}
