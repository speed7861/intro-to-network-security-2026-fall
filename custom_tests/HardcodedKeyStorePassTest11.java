import java.security.KeyStore;

public class HardcodedKeyStorePassTest11 {
    public static void main(String[] args) throws Exception {
        KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        char[] password = "changeit123".toCharArray();
        ks.load(null, password);
    }
}
