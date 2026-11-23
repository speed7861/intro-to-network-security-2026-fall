# Root-cause probes

Small test files that each change one thing about a case CryptoGuard misses, so we can see which change makes the difference. They are not part of the scored test suite.

- `key/` varies how a hard-coded AES key reaches `SecretKeySpec`: a literal or a local variable, with or without `Arrays.copyOf`, or padded with `System.arraycopy`. `KeyLocalGetBytesCopyOf` is the same code as the benchmark case `PredictableCryptographicKeyBBCase1`.
- `rsa/` varies where a small RSA key size is set: directly in `main`, in a helper method without parameters, or in a helper method with an array parameter. `RsaInMainLiteral512` is the same code as Abdul's `SmallRSAKeyTest10`.

Run them with:

```bash
bash harness/probes.sh <run_id>
```

Each probe is compiled into its own jar and run through CG-2019, CG-2019 with refinement off, and CG-2020. The table goes to `runs/<run_id>/probes/PROBES.md`. What the results mean is explained in `docs/results.md`, section 4.
