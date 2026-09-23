# Experiment NN — <short title>

Copy this file to `results/NN-short-name-yourname.md` and fill it in as you go.

## Identification

| Field | Value |
| --- | --- |
| Experiment | |
| Date | |
| Team member | |
| Branch / commit | |

## Environment

| Field | Value |
| --- | --- |
| Operating system | e.g. Windows 11 + WSL2 (Ubuntu 22.04) |
| Docker version | output of `docker --version` |
| SAW image | `ghcr.io/galoisinc/saw:1.6` |
| SAW version banner | version line printed by the container |
| Proof assistant + version | e.g. Isabelle2024 / not installed |

## Inputs and target

| Field | Value |
| --- | --- |
| Cryptol input | `examples/Example.cry` |
| SAW script | `saw/extract_isabelle.saw` |
| Extraction target | Isabelle / Rocq |
| Output path | `outputs/isabelle/Example.thy` |

## Outcome

| Step | Result |
| --- | --- |
| Cryptol module loaded | Yes / No |
| Public symbols listed correctly | Yes / No |
| `enable_experimental` accepted | Yes / No |
| Extraction command found | Yes / No |
| Extraction succeeded | Yes / No |
| Generated file present on host | Yes / No |
| Proof assistant loaded the file | Yes / No / Not attempted |
| Proof attempted | Yes / No |
| Proof succeeded | Yes / No / Not attempted |

## Commands run

```bash
# paste the exact commands, including the docker invocation
```

## Output

```text
# paste the SAW transcript, trimmed but not paraphrased
```

## Errors

Full error text, verbatim. If there were none, say "none".

## Manual changes required

Anything you had to change by hand to get this far. For each one:

- **What changed:**
- **Why:**
- **Needed for extraction, or only for the proof?**
- **Can another member reproduce it from these notes alone?**

If nothing was changed by hand, say so explicitly — that is a meaningful result.

## Known limitations encountered

Note any of: recursive functions, parameterized modules requiring wrappers,
infinite/stream types, or anything else the tooling refused to translate.

## Time spent

Rough hours, split between setup and the experiment itself. This feeds the
"setup difficulty" row of the Rocq/Isabelle comparison.

## Next step

What the next person should try, and what you would do differently.
