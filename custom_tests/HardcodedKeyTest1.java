import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class HardcodedKeyTest1 {
    public static void main(String[] args) throws Exception {
        byte[] keyBytes = "1234567890123456".getBytes();
        SecretKeySpec key = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, key);
    }
}
