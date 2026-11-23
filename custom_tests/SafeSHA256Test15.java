import java.security.MessageDigest;

public class SafeSHA256Test15 {
    public static void main(String[] args) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] digest = md.digest("SecureMessage".getBytes());
    }
}
