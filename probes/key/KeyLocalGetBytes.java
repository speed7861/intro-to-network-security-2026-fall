// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import javax.crypto.spec.SecretKeySpec;

/** Constant key: the string is stored in a local variable first, then getBytes(). */
public class KeyLocalGetBytes {
    public static void main(String[] args) {
        String defaultKey = "defaultkey";
        byte[] keyBytes = defaultKey.getBytes();
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
    }
}
