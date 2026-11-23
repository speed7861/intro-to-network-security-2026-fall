// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.security.KeyPairGenerator;

/** Same code as RsaInMainVariable1024, moved into an instance method that main calls. */
public class RsaInInstanceMethodVariable1024 {
    public void go() throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        int keysize = 1024;
        keyGen.initialize(keysize);
        keyGen.generateKeyPair();
    }

    public static void main(String[] args) throws Exception {
        new RsaInInstanceMethodVariable1024().go();
    }
}
