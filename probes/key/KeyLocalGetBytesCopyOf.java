// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.util.Arrays;
import javax.crypto.spec.SecretKeySpec;

/** Constant key passed through Arrays.copyOf. Same code as benchmark case PredictableCryptographicKeyBBCase1. */
public class KeyLocalGetBytesCopyOf {
    public static void main(String[] args) {
        String defaultKey = "defaultkey";
        byte[] keyBytes = defaultKey.getBytes();
        keyBytes = Arrays.copyOf(keyBytes, 16);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
    }
}
