package custom.pilot;

import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

/** PILOT P1 (paper Section 7, false negatives): a hard-coded AES key decoded through a helper call.
 *  The paper predicts RI-II drops "6A5B7C8A..." as a pseudo-influence when the orthogonal
 *  call parseHexBinary is clipped -> expected CryptoGuard MISS. Ground truth: misuse (rule 1). */
public class PilotClippedHexKey {
    public static void main(String[] args) {
        byte[] key = DatatypeConverter.parseHexBinary("6A5B7C8A6A5B7C8A6A5B7C8A6A5B7C8A");
        SecretKeySpec spec = new SecretKeySpec(key, "AES");
        System.out.println(spec.getAlgorithm());
    }
}
