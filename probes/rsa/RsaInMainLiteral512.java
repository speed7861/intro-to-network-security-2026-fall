// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.security.KeyPairGenerator;

/** RSA-512 with the key size as a literal, directly in main (same shape as SmallRSAKeyTest10). */
public class RsaInMainLiteral512 {
    public static void main(String[] args) throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(512);
        keyGen.generateKeyPair();
    }
}
