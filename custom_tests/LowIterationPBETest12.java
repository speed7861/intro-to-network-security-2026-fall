import javax.crypto.spec.PBEParameterSpec;

public class LowIterationPBETest12 {
    public static void main(String[] args) {
        byte[] salt = {1, 2, 3, 4, 5, 6, 7, 8};
        PBEParameterSpec pbeSpec = new PBEParameterSpec(salt, 100); // أقل من 1000
    }
}
