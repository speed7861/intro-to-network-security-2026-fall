// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import javax.crypto.spec.SecretKeySpec;

/** Constant key padded by hand with System.arraycopy instead of Arrays.copyOf. */
public class KeyLocalGetBytesArraycopy {
    public static void main(String[] args) {
        String defaultKey = "defaultkey";
        byte[] raw = defaultKey.getBytes();
        byte[] keyBytes = new byte[16];
        System.arraycopy(raw, 0, keyBytes, 0, raw.length);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
    }
}
