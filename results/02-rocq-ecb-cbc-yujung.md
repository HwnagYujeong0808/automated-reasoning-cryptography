# Experiment 02 — Cryptol to Rocq Validation (ECB, CBC)

## Identification

| Field | Value |
| --- | --- |
| Experiment | 02 — Cryptol to Rocq validation |
| Date | 2026-10-31 |
| Team member | Yujung |
| Branch / commit | `yujung`; exact commit in the first lines of `results/replay-*.log` |

## Environment

| Field | Value |
| --- | --- |
| Operating system | Windows 11 + WSL2 (Ubuntu 24.04.1), 16 cores |
| Docker version | 29.8.0 |
| SAW image | `ghcr.io/galoisinc/saw:1.6` |
| Proof assistant + version | Rocq 9.1.1 (`rocq/saw-core-rocq.Dockerfile`) |
| AWS host | Not run: port 22 timed out on 2026-10-31 |

## Inputs and target

| Field | Value |
| --- | --- |
| Cryptol input | `examples/ECB.cry`, `examples/CBC.cry`, and their `Wrapper.cry` |
| SAW script | `saw/extract_rocq.saw` |
| Extraction target | Rocq |
| Output path | `outputs/rocq/ECB/Wrapper.v`, `outputs/rocq/CBC/Wrapper.v` |

## Outcome

| Step | ECB | CBC |
| --- | --- | --- |
| Extraction succeeded | Yes, byte-identical to the mentor's `Wrapper.v` | Yes |
| Rocq compiled the wrapper | Yes | Yes |
| Proof succeeded | Yes | Yes |
| Axioms used | `error` only | `error` only |

## Commands run

```bash
./replay.sh
```

## Output

See `results/replay-*.log`. It is the unedited transcript of a clean-clone run.

## Errors

| Error | Cause | Fix (all in `replay.sh`) |
| --- | --- | --- |
| `cannot attach stdin to a TTY-enabled container` | `docker run -it` in a script | Dropped `-it` |
| `Unable to find image 'rocq:latest'` | README typo `--rm -v -u`: `-v` eats `-u` | Dropped the stray `-v` |
| `invalid volume specification: ...:WD` | README typo `"$PWD:WD"` | Mount to `/work` |
| `No rule to make target 'saw-core/.../CryptolPrimitivesForSAWCore.vo'` | README never compiles the scaffolding | Compile saw-core first |
| `Could not find SAW (including via cabal)` | saw-core-rocq's Makefile requires `saw` | Use `rocq makefile` directly |
| `Opam has not been initialised` | Image entrypoint only works as uid 1000 | `--entrypoint sh` plus opam `PATH` |

## Notes

- A broken CBC `decrypt` (dropping `^ prev`) still extracts, then fails at
  `rocq/CBC/Proof.v` with exit code 2.
- A recursive CBC `encrypt` (`cts = ... [iv] # cts`) makes SAW print
  `Malformed term` and exit 0 without writing `Wrapper.v`. `examples/CBC.cry`
  uses `scanl` for that reason, and `replay.sh` deletes old wrappers before
  extraction so this cannot pass silently.
- `examples/ECB.cry` was replaced by the mentor's version. The old version put
  `fin` on `encrypt`, which does not match the proofs.
