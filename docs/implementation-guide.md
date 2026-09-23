# Implementation Guide

The working document for the training phase of the Automated Reasoning for
Cryptography project. It covers what we are building, how to run the first
experiment, and what to record.

- New to the project? Read sections 1-3, then do [setup.md](setup.md).
- Set up already? Go straight to section 5, Experiment 1.

---

## 1. Project goal

We are investigating how cryptographic specifications written in **Cryptol**
can be translated through **SAW** (the Software Analysis Workbench) into
interactive proof assistants, and formally verified there.

```
Cryptol specification  ->  SAW  ->  Rocq / Isabelle  ->  Formal verification
```

During the training phase the objective is **not** to verify a complete
cryptographic algorithm. It is to establish a **reproducible toolchain** and
understand how a Cryptol specification actually moves through SAW into a
proof-assistant representation.

The first experiment reproduces the example given by our problem mentor, using
SAW 1.6 and its experimental Cryptol-to-Isabelle extraction:

```
Example.cry
    -> Cryptol specification
    -> SAW 1.6
    -> Cryptol-to-Isabelle extraction
    -> Example.thy
```

Once that works we can compare the more mature **Rocq** extraction against the
newer experimental **Isabelle** one, and decide which fits the project.

## 2. What we need to accomplish

1. Set up a reproducible Docker environment.
2. Run SAW 1.6.
3. Create and load a simple Cryptol specification.
4. Confirm SAW recognizes the Cryptol module.
5. Enable SAW's experimental Isabelle functionality.
6. Extract the Cryptol module into an Isabelle theory.
7. Confirm `Example.thy` is generated correctly.
8. If possible, load the generated theory into Isabelle.
9. Later, attempt to prove one or more of the extracted properties.
10. Document errors, limitations, and manual intervention required.
11. Compare the Isabelle workflow with the Rocq workflow.
12. Use the results to select the proof-assistant path for the main
    cryptographic target.

Items 1-7 are the training phase. The emphasis is on **reproducibility and
extraction**, not on a complete cryptographic proof.

## 3. Repository layout

```
automated-reasoning-cryptography/
├── README.md
├── img/pipeline.png
├── examples/Example.cry            # Cryptol source specifications
├── saw/                            # SAW scripts + the docker launcher
├── rocq/                           # Rocq notes and hand-written proofs
├── isabelle/                       # Isabelle notes and hand-written proofs
├── outputs/
│   ├── isabelle/                   # GENERATED - Example.thy lands here
│   └── rocq/                       # GENERATED
├── docs/
│   ├── implementation-guide.md     # this file
│   ├── setup.md
│   └── training-notes.md
└── results/                        # one file per experiment run
```

The split that matters: `examples/` and `saw/` are **inputs we write**,
`outputs/` is **what the tool produces**, and `results/` is **what happened
when we ran it**. Keeping generated files out of the hand-written directories
is what makes a later diff meaningful.

## 4. The Cryptol example

[examples/Example.cry](../examples/Example.cry), provided by the problem
mentor:

```cryptol
module Example where

add_assoc_l: {a} (Eq a, Ring a) => a -> a -> a -> Bool
property add_assoc_l x y z = x + (y + z) == (x + y) + z

add_comm: {a} (Eq a, Ring a) => a -> a -> Bool
property add_comm x y = x + y == y + x

dist_l: {a} (Eq a, Ring a) => a -> a -> a -> Bool
property dist_l x y z = x * (y + z) == x * y + x * z

dist_r: {a} (Eq a, Ring a) => a -> a -> a -> Bool
property dist_r x y z = (x + y) * z == x * z + y * z
```

Four basic ring-arithmetic laws: addition associativity, addition
commutativity, left distributivity, right distributivity.

The point is not to study these properties. They are a small, readable
specification that exercises the whole pipeline - and being polymorphic over
`Ring a`, they also tell us something about how SAW handles Cryptol's type
classes during translation.

## 5. Experiment 1 - Cryptol to Isabelle

Prerequisite: [setup.md](setup.md) finished, and

```bash
docker pull ghcr.io/galoisinc/saw:1.6
```

### The short way

From the repository root, in WSL/Ubuntu or Linux:

```bash
./saw/run-saw.sh saw/extract_isabelle.saw
```

### The long way, step by step

Run these the first time, so you can see where each stage fails.

**5.1 Start the container.**

```bash
CUSER="saw"
WD="/home/$CUSER/$(basename "$PWD")"

docker run --rm -it \
  -u "$CUSER" \
  -v "$PWD:$WD" \
  -w "$WD" \
  -e "CRYPTOLPATH=$WD" \
  ghcr.io/galoisinc/saw:1.6
```

What each flag buys you:

| Flag | Effect |
| --- | --- |
| `-v "$PWD:$WD"` | Mounts this repository inside the container, so files SAW writes are visible on the host |
| `-w "$WD"` | Makes the repository the working directory inside the container |
| `-e CRYPTOLPATH=$WD` | Puts the repository on Cryptol's module search path |
| `--rm` | Throws the container away on exit; the repo mount is what persists |

You should get a `sawscript>` prompt showing SAW 1.6.

**5.2 Load the Cryptol module.**

```
sawscript> Example <- cryptol_load "examples/Example.cry"
sawscript> Example
```

Expect the loaded module and its public symbols: `add_assoc_l`, `add_comm`,
`dist_l`, `dist_r`. If they appear, `Cryptol -> SAW` works.

**5.3 Enable the experimental commands.**

```
sawscript> enable_experimental
sawscript> :h write_isabelle_cryptol_modules
```

The help text should describe translating Cryptol modules into Isabelle
theories. The command does not exist before `enable_experimental`, and each
new SAW session needs it again.

**5.4 Extract.**

The mentor's original call writes to the working directory:

```
sawscript> write_isabelle_cryptol_modules [Example] [] ""
```

For this repository, target the outputs directory instead:

```
sawscript> write_isabelle_cryptol_modules [Example] [] "outputs/isabelle"
```

SAW should report that the theory was translated. Expected result:

```
outputs/isabelle/Example.thy
```

The pipeline has then reached:

```
Example.cry -> Cryptol -> SAW 1.6 -> Isabelle extraction -> Example.thy
```

**This is the minimum successful outcome of the first experiment.**

### 5.5 Inspect the generated theory

Open `outputs/isabelle/Example.thy`. It should look roughly like:

```isabelle
theory "Example"

imports "Cryptol.Cryptol"

begin

context includes cryptol_translation_syntax begin

...

end

end
```

with definitions corresponding to `add_assoc_l`, `add_comm`, `dist_l`, and
`dist_r`.

Do **not** hand-edit the generated file just to make the experiment look
successful. If a manual change really is necessary, record in `results/`:

- What was changed?
- Why was it changed?
- Was the change required for extraction, or only for the proof?
- Can another team member reproduce it from your notes?

Reproducibility is one of the project's deliverables.

## 6. Experiment 2 - the Rocq path

The mentor described SAW's Rocq extraction as more mature than the Isabelle
one, but gave us a verified command sequence only for Isabelle. So we reproduce
Isabelle first, then find the Rocq equivalent ourselves.

```
                   +--> Rocq
Cryptol -> SAW ----+
                   +--> Isabelle
```

See the [Rocq section of the README](../README.md#rocq) for how to find the
command (`:env` inside SAW, then `:h`), and fill the result into
[saw/extract_rocq.saw](../saw/extract_rocq.saw).

## 7. Proof attempts

Generating `Example.thy` and proving its properties are two different stages,
and the mentor demonstrated only the first. Hence two levels of success:

**Minimum goal.** Reproduce `examples/Example.cry` -> SAW 1.6 ->
`outputs/isabelle/Example.thy`.

**Stretch goal.** Install Isabelle, load the generated theory, resolve its
Cryptol support-library dependencies, attempt one simple property, and record
the proof strategy and any errors. `add_comm` and `add_assoc_l` are the best
first candidates.

The question we are answering is *how much manual proof work remains after
extraction* - see the [Isabelle section of the README](../README.md#isabelle)
for the checklist.

## 8. Known limitations

Reported by the problem mentor for the current extraction support:

- Recursive functions
- Parameterized modules requiring wrappers
- Infinite / stream types

Record it whenever one of these shows up. This matters beyond bookkeeping: the
cryptographic specification we eventually target has to be compatible with the
extraction pipeline, and a spec built on unsupported recursion is a bad first
choice no matter how interesting it is otherwise.

## 9. Recording an experiment

Every run gets a file in `results/`, copied from
[results/experiment-template.md](../results/experiment-template.md). It
captures OS, Docker and SAW versions, input and target, whether the load and
extraction succeeded, the generated path, whether the proof assistant loaded
the file, proof outcome, verbatim errors, manual changes, limitations hit, and
the next step.

Fill it in while you run, not from memory afterwards, and paste real terminal
output rather than paraphrasing. These files become the evidence base for the
final technical report.

## 10. Git workflow

GitHub stores the specifications, scripts, generated files, setup docs, results
and notes - but it is not where the work runs:

```
GitHub -> git clone/pull -> your machine -> Docker -> SAW -> results -> git push -> GitHub
```

Before starting:

```bash
git pull
```

Work on a branch named `yourname/experiment-name`:

```bash
git checkout -b yujung/isabelle-extraction
```

Then run the experiment, write the results file, and:

```bash
git status
git add .
git commit -m "Reproduce Cryptol to Isabelle extraction"
git push origin yujung/isabelle-extraction
```

Open a pull request for team review. Four people editing the same files
directly on `main` is the failure mode this avoids.

## 11. First milestone

```
examples/Example.cry
        -> SAW 1.6 Docker container
        -> cryptol_load
        -> write_isabelle_cryptol_modules
        -> outputs/isabelle/Example.thy
```

The milestone is met when a team member can clone this repository onto a
*different* computer, follow [setup.md](setup.md) and section 5, and get the
same output. That - not the file itself - is the evidence that the toolchain is
reproducible.

## 12. What comes after

1. Reproduce simple Cryptol -> SAW -> Isabelle extraction.
2. Reproduce the corresponding Rocq extraction.
3. Compare Rocq and Isabelle.
4. Select the proof assistant.
5. Select a feasible cryptographic specification.
6. Extract the specification.
7. Define meaningful mathematical correctness properties.
8. Attempt formal proof.
9. Document unsupported constructs and manual interventions.
10. Evaluate the complete workflow.

The final goal is not to show that SAW can emit another file format. It is to
determine whether a realistic cryptographic specification can move through

**Cryptol -> SAW -> proof assistant -> mathematical validation**

and to state clearly what can be automated, what still requires manual work,
and which current limitations block full verification.
