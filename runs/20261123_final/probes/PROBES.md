# Root-cause probes

Each probe is compiled on its own and run through each tool. Only alerts for the probe's own rule are shown
(constant key for `key/`, small RSA key for `rsa/`). Sources are in `probes/`.

| Probe | CG-2019 | CG-2019, refinement off | CG-2020 |
|---|---|---|---|
| `key/KeyLiteralGetBytes` | detected ["defaultkey"] | detected ["defaultkey", 0] | detected Found: Constant "defaultkey" |
| `key/KeyLiteralGetBytesCopyOf` | missed | missed | detected Found: Constant "defaultkey" |
| `key/KeyLocalGetBytes` | detected ["defaultkey"] | detected ["defaultkey", 0] | missed |
| `key/KeyLocalGetBytesArraycopy` | missed | detected [16] | missed |
| `key/KeyLocalGetBytesCopyOf` | missed | missed | missed |
| `rsa/RsaInHelperWithArrayParam512` | missed | missed | missed |
| `rsa/RsaInInstanceMethodVariable1024` | detected [1024] | detected [1024] | detected Found: "1024" |
| `rsa/RsaInMainLiteral512` | missed | missed | missed |
| `rsa/RsaInMainVariable1024` | missed | missed | missed |
| `rsa/RsaInMainWithCipher` | missed | missed | missed |
| `rsa/RsaInStaticHelperLiteral512` | detected [512] | detected [512] | detected Found: "512" |
