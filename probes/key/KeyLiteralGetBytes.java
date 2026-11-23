// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import javax.crypto.spec.SecretKeySpec;

/** Constant key: getBytes() called directly on the string literal (same shape as HardcodedKeyTest1). */
public class KeyLiteralGetBytes {
    public static void main(String[] args) {
        byte[] keyBytes = "defaultkey".getBytes();
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
    }
}
