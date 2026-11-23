import java.util.Random;
import javax.crypto.spec.SecretKeySpec;

public class InsecureRandomTest8 {
    public static void main(String[] args) {
        Random random = new Random();
        byte[] keyBytes = new byte[16];
        random.nextBytes(keyBytes);
        SecretKeySpec key = new SecretKeySpec(keyBytes, "AES");
    }
}
