// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.security.KeyPairGenerator;

/** Same code as RsaInStaticHelperLiteral512, but the helper method takes an array parameter. */
public class RsaInHelperWithArrayParam512 {
    static void go(byte[] unused) throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(512);
        keyGen.generateKeyPair();
    }

    public static void main(String[] args) throws Exception {
        go(new byte[0]);
    }
}
