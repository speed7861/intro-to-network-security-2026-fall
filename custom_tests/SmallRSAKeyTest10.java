import java.security.KeyPairGenerator;

public class SmallRSAKeyTest10 {
    public static void main(String[] args) throws Exception {
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(512);
        keyGen.generateKeyPair();
    }
}
