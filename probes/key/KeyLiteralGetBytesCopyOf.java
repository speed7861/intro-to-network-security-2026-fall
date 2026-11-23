// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.util.Arrays;
import javax.crypto.spec.SecretKeySpec;

/** Constant key: literal getBytes() (detected on its own) passed through Arrays.copyOf. */
public class KeyLiteralGetBytesCopyOf {
    public static void main(String[] args) {
        byte[] keyBytes = Arrays.copyOf("defaultkey".getBytes(), 16);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
    }
}
