import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class ObfuscatedKeySliceTest13 {
    private static byte[] getSecretBytes() {
        return new StringBuilder("6543210987654321").reverse().toString().getBytes();
    }

    public static void main(String[] args) throws Exception {
        SecretKeySpec key = new SecretKeySpec(getSecretBytes(), "AES");
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, key);
    }
}
