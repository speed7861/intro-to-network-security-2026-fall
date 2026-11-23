import java.security.SecureRandom;

public class StaticSeedSecureRandomTest9 {
    public static void main(String[] args) {
        SecureRandom sr = new SecureRandom();
        sr.setSeed(12345L);
        byte[] bytes = new byte[16];
        sr.nextBytes(bytes);
    }
}
