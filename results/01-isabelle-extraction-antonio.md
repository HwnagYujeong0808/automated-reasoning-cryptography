
# Experiment 01 — Cryptol to Isabelle Extraction

## Identification

| Field | Value |
| --- | --- |
| Experiment | 01 — Cryptol to Isabelle Extraction |
| Date | 2026-09-23 |
| Team member | Antonio Musumeci |
| Branch / commit | main / 827be38 |

## Environment

| Field | Value |
| --- | --- |
| Operating system | Ubuntu 26.04.1 LTS on AWS EC2 |
| Kernel | 7.0.0-1013-aws |
| Docker version | Docker 29.1.3, build 29.1.3-0ubuntu4.1 |
| SAW image | ghcr.io/galoisinc/saw:1.6 |
| SAW version banner | SAW version 1.6 (68eed5f release-1.6) |
| Cryptol version | Cryptol 2.9.1 (cryptolcourse/dev) |
| Proof assistant + version | Isabelle not installed; extraction only |

## Inputs and target

| Field | Value |
| --- | --- |
| Cryptol input | examples/Example.cry |
| SAW script | saw/extract_isabelle.saw |
| Extraction target | Isabelle |
| Output path | outputs/isabelle/Example.thy |

## Outcome

| Step | Result |
| --- | --- |
| Cryptol module loaded | Yes |
| Public symbols listed correctly | Yes — add_assoc_l, add_comm, dist_l, dist_r |
| enable_experimental accepted | Yes |
| Extraction command found | Yes |
| Extraction succeeded | Yes, using the manual SAW container workflow |
| Generated file present on host | Yes — Example.thy (929 bytes) |
| Proof assistant loaded the file | Not attempted |
| Proof attempted | Not attempted in Isabelle |
| Proof succeeded | Not attempted in Isabelle |

## Commands run

```bash
git clone https://github.com/HwnagYujeong0808/automated-reasoning-cryptography.git
cd automated-reasoning-cryptography
mkdir -p outputs/isabelle

sudo docker pull ghcr.io/galoisinc/saw:1.6

CUSER="saw"
WD="/home/$CUSER/$(basename "$PWD")"

sudo docker run --rm -it \
  -u "$CUSER" \
  -v "$PWD:$WD" \
  -w "$WD" \
  -e "CRYPTOLPATH=$WD" \
  ghcr.io/galoisinc/saw:1.6

```

Inside SAW:

```text
Example <- cryptol_load "examples/Example.cry"
Example
enable_experimental
write_isabelle_cryptol_modules [Example] [] "outputs/isabelle"
:quit
```

## Verification

```bash
ls -lh outputs/isabelle
head -n 30 outputs/isabelle/Example.thy
```

## Cryptol training

```bash
sudo docker pull cryptolcourse/dev

sudo docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  cryptolcourse/dev \
  -c '/usr/local/bin/cryptol'
```

Inside Cryptol:

```text
:load examples/Example.cry
:check (add_comm : [8] -> [8] -> Bool)
:prove (add_comm : [8] -> [8] -> Bool)
:sat (add_comm : [8] -> [8] -> Bool)
:browse
:quit
```

## Output

SAW successfully loaded the Cryptol module and identified:

```text
add_assoc_l
add_comm
dist_l
dist_r
```

The Isabelle extraction completed successfully:

```text
Successfully translated theory Example
Translation successful. Generating theory files...
Generating Example.thy
Successfully wrote 'outputs/isabelle/Example.thy'
```

The generated file was present on the EC2 host:

```text
outputs/isabelle/Example.thy
Size: 929 bytes
```

Cryptol testing:

```text
:check (add_comm : [8] -> [8] -> Bool)

Using random testing.
Passed 100 tests.
Expected test coverage: 0.15% (100 of 65536 values)
```

Cryptol proving:

```text
:prove (add_comm : [8] -> [8] -> Bool)

Q.E.D.
(Total Elapsed Time: 0.005s, using "Z3")
```

Cryptol satisfiability:

```text
:sat (add_comm : [8] -> [8] -> Bool)

Satisfiable
(add_comm : [8] -> [8] -> Bool) 0x00 0x00 = True
(Total Elapsed Time: 0.005s, using "Z3")
```

## Errors

The SAW 1.6 container did not expose a standalone Cryptol CLI. A separate
`cryptolcourse/dev` container was therefore used for Cryptol REPL training.

The repository launcher initially did not have executable permission:

```text
Permission denied
```

The executable bit was added with:

```bash
chmod +x saw/run-saw.sh
```

Docker initially denied access to `/var/run/docker.sock` when the wrapper was
executed without sudo. The Ubuntu user was added to the Docker group.

The repository wrapper successfully loaded and translated the Cryptol module,
but failed during the final output-write step:

```text
Failed to write output file 'outputs/isabelle/Example.thy':
outputs/isabelle/Example.thy: withFile: does not exist
(No such file or directory)
```

The output directory was independently confirmed to exist and be visible from
a directly mounted Docker container. The exact cause of the wrapper failure
remains unresolved. Manual SAW execution successfully generated the output.

Directly running:

```text
:check add_comm
```

failed because the property is polymorphic. It was specialized to an 8-bit
word type:

```text
(add_comm : [8] -> [8] -> Bool)
```

After specialization, `:check`, `:prove`, and `:sat` worked successfully.

## Manual changes required

- Added executable permission to `saw/run-saw.sh`.
- Added the Ubuntu user to the Docker group so the repository wrapper could
  invoke Docker without sudo.
- No manual modification was made to `Example.cry`.
- No manual modification was made to the generated `Example.thy`.

## Known limitations encountered

The example properties are polymorphic over `Ring a`. Cryptol interactive
testing and proving therefore required specialization to a concrete finite
type (`[8]`) for the demonstrated commands.

No recursive-function, parameterized-module, or infinite-stream translation
limitation was tested during this experiment.

The generated Isabelle theory has not yet been loaded into Isabelle.
Proof-assistant compatibility and Isabelle proof automation therefore remain
unverified.

## Time spent

Approximately 1 hour for AWS EC2, Docker, and tool setup, plus approximately
1 hour for the Cryptol/SAW experiment, testing, and troubleshooting.

## Next step

Install or configure Isabelle and determine how the generated `Example.thy`
loads with the required `Cryptol.Cryptol` support library.

Determine whether the extracted Cryptol properties are directly usable as
provable statements or whether separate Isabelle lemmas/goals must be created.

After the Isabelle workflow is understood, reproduce the corresponding Rocq
extraction experiment for comparison.
