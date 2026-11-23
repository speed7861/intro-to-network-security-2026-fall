// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.security.KeyPairGenerator;

/** Same code as RsaInMainLiteral512, moved into a static method that main calls. */
public class RsaInStaticHelperLiteral512 {
    static void go() throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(512);
        keyGen.generateKeyPair();
    }

    public static void main(String[] args) throws Exception {
        go();
    }
}
