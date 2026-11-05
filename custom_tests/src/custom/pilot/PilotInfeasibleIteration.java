package custom.pilot;

import javax.crypto.spec.PBEKeySpec;
import java.security.SecureRandom;

/** PILOT P2 (paper §7, false positives): the jackrabbit-oak pattern. iteration=0 is
 *  overwritten on every path before use, so the real count is 10000. The paper predicts a
 *  path-insensitive FALSE ALARM on the constant 0. Ground truth: secure (rule 13). */
public class PilotInfeasibleIteration {
    static final int NO_ITERATION = 1;
    static final int DEFAULT_ITERATION = 10000;

    public static void main(String[] args) {
        int iteration = 0;
        if (iteration < NO_ITERATION) {
            iteration = DEFAULT_ITERATION;
        }
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        PBEKeySpec spec = new PBEKeySpec(args[0].toCharArray(), salt, iteration, 256);
        System.out.println(spec.getIterationCount());
    }
}
