// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.security.KeyPairGenerator;

/** RSA-1024 with the key size in a local variable (the benchmark's style), directly in main. */
public class RsaInMainVariable1024 {
    public static void main(String[] args) throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        int keysize = 1024;
        keyGen.initialize(keysize);
        keyGen.generateKeyPair();
    }
}
