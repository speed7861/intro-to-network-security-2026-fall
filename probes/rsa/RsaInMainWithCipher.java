// Root-cause probe. See probes/README.md and runs/<run>/probes/PROBES.md.
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import javax.crypto.Cipher;

/** RSA-1024 directly in main, and the key pair is used by an RSA Cipher (like the benchmark case). */
public class RsaInMainWithCipher {
    public static void main(String[] args) throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        int keysize = 1024;
        keyGen.initialize(keysize);
        KeyPair kp = keyGen.generateKeyPair();
        Cipher cipher = Cipher.getInstance("RSA");
        cipher.init(Cipher.ENCRYPT_MODE, kp.getPublic());
    }
}
