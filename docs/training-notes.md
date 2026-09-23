# Training Notes

A running log for the training phase. Short entries, added as we learn things —
this is the scratchpad that feeds the final technical report. Per-run detail
goes in `results/` instead; what belongs here is anything the next person would
otherwise have to rediscover.

## How to add an entry

Newest first, under **Log**. Date it, sign it, keep it to a few lines:

```markdown
### 2026-09-23 — yujung — SAW REPL: experimental commands
`write_isabelle_cryptol_modules` does not exist until `enable_experimental`
runs, and it has to be re-run in every new session.
```

---

## Open questions

Things we do not know yet. Cross them off (and say where the answer came from)
as they get resolved.

- [ ] Where does the Isabelle `Cryptol.Cryptol` support library live, and how do
      we register it with a stock Isabelle install?
- [ ] What is the exact Rocq/Coq extraction command name in SAW 1.6, and what
      are its arguments?
- [ ] Which support library do generated Rocq files need, and does it still
      build against a current Rocq?
- [ ] How does the translation handle Cryptol's type classes (`Eq`, `Ring`)?
      Our example is polymorphic, so the generated theory has to say something
      about `a` — does it stay polymorphic, or get monomorphized?
- [ ] Are the extracted properties stated as provable Isabelle lemmas, or only
      as definitions we then have to state goals about ourselves?
- [ ] Do all four of us get byte-identical output from the same image?
- [ ] Which of the known limitations (recursion, parameterized modules,
      infinite/stream types) will actually block a realistic crypto target?

## Rocq vs Isabelle

Fill in from our own runs, not from reputation. Every row should be traceable
to a file in `results/`.

| Criterion | Rocq | Isabelle |
| --- | --- | --- |
| Extraction works | TBD | TBD |
| Setup difficulty | TBD | TBD |
| Manual intervention | TBD | TBD |
| Proof support | TBD | TBD |
| Automation | TBD | TBD |
| Documentation | TBD | TBD |
| Cryptographic libraries | TBD | TBD |
| Reproducibility | TBD | TBD |

Scoring notes:

- **Setup difficulty** — hours from clone to first loaded theory, including
  hunting for the support library. Take it from the "time spent" field of the
  results files.
- **Manual intervention** — how many hand edits stood between extraction and a
  file the proof assistant would accept. Zero is the number we want.
- **Automation** — did `simp`/`auto`/`sledgehammer` (or `auto`/`lia`/`ring` on
  the Rocq side) close the goals, or did each property need a hand-written
  proof?
- **Cryptographic libraries** — what already exists for the kind of target we
  eventually want (bitvectors, modular arithmetic, finite fields).
- **Reproducibility** — did the same steps work on all four machines?

We do not have to choose a proof assistant before both experiments are done.
Choosing early on a hunch is the thing to avoid.

## Decisions

Record decisions here with the reason, so we do not re-argue them later.

| Date | Decision | Why |
| --- | --- | --- |
| 2026-09-23 | Pin SAW to `ghcr.io/galoisinc/saw:1.6` | Matches the mentor's demonstrated environment; keeps the four of us comparable |
| 2026-09-23 | Reproduce Isabelle before Rocq | The mentor gave a known-good command sequence for Isabelle only |
| 2026-09-23 | Commit generated files under `outputs/` | The diff between runs and versions is itself evidence about the toolchain |

## Log

### 2026-09-23 — repository scaffolding
Set up the directory layout, the Cryptol example, the SAW scripts, and the
experiment template. Nothing has been run against SAW yet — every "expected
output" in the docs comes from the mentor's description, not from our own
observation, and should be treated as unverified until a `results/` file backs
it up.
