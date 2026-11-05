package custom.pilot;

import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

/** PILOT P3 (negative control): AES key from KeyGenerator, no constants reach the key.
 *  Ground truth: secure (rule 1). Any rule-1 alert here is a false positive. */
public class PilotSecureKey {
    public static void main(String[] args) throws Exception {
        KeyGenerator kg = KeyGenerator.getInstance("AES");
        kg.init(256);
        SecretKey k = kg.generateKey();
        SecretKeySpec spec = new SecretKeySpec(k.getEncoded(), "AES");
        System.out.println(spec.getAlgorithm());
    }
}
