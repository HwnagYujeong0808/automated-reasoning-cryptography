# Setup

Goal: get to a point where you can run the SAW 1.6 container against this
repository. Budget an hour the first time, mostly Docker install and download.

Everything is pinned to one image, `ghcr.io/galoisinc/saw:1.6`, so that all
four of us run the same SAW. If you change the image, say so in `results/`.

---

## Windows

Target environment:

```
Windows  ->  WSL2  ->  Ubuntu  ->  Docker Desktop  ->  SAW 1.6 container
```

WSL2 is not optional bureaucracy: the project commands are Bash, and rewriting
them for PowerShell is how the four of us end up with four different setups.

### 1. Install WSL2

In **PowerShell as Administrator**:

```powershell
wsl --install
```

Restart Windows if asked, then confirm:

```powershell
wsl --version
```

Ubuntu is then available from the Start menu or Windows Terminal.

### 2. Install Docker Desktop

Install Docker Desktop and enable the WSL 2 backend. Then check:

```
Settings -> Resources -> WSL Integration -> Ubuntu enabled
```

Open Ubuntu and verify Docker is reachable from inside WSL:

```bash
docker --version
docker run hello-world
```

If `hello-world` prints its greeting, the environment is ready. If you get
`permission denied` on the Docker socket, WSL integration is not enabled for
this distro — go back to the settings above.

### 3. Clone the repository

From the **Ubuntu** terminal:

```bash
git clone https://github.com/HwnagYujeong0808/automated-reasoning-cryptography.git
cd automated-reasoning-cryptography
```

Clone into the Linux filesystem (`~/`), not `/mnt/c/...`. Bind mounts across
the Windows filesystem boundary are slow and have their own permission quirks;
this is the single most common source of "it works on my machine" here.

Run every project command from Ubuntu, not from PowerShell.

---

## Linux

Docker Engine directly:

```bash
docker --version
docker run hello-world
```

```bash
git clone https://github.com/HwnagYujeong0808/automated-reasoning-cryptography.git
cd automated-reasoning-cryptography
```

Depending on your Docker install, these may need `sudo` (or add yourself to the
`docker` group). If you use `sudo`, note it in your results file — it changes
who owns the generated files.

---

## macOS

Not part of the documented path, but Docker Desktop for Mac works. On Apple
silicon the image is x86-64, so Docker runs it under emulation: it works but is
slow, and you may see a platform warning. Add `--platform linux/amd64` if
Docker complains, and record that you needed it.

---

## Pull the SAW image

From the repository root:

```bash
docker pull ghcr.io/galoisinc/saw:1.6
```

This is a large download. Do it once, before the meeting where you plan to run
the experiment.

---

## Verify the setup

```bash
./saw/run-saw.sh
```

You should land at a `sawscript>` prompt showing SAW 1.6. Then:

```
sawscript> Example <- cryptol_load "examples/Example.cry"
sawscript> Example
```

The module's public symbols should be listed: `add_assoc_l`, `add_comm`,
`dist_l`, `dist_r`. Type `:q` to leave.

If that worked, go to `docs/implementation-guide.md` and run Experiment 1.

---

## Troubleshooting

**`docker: command not found` in Ubuntu.** Docker Desktop's WSL integration is
off for this distro. Settings -> Resources -> WSL Integration.

**`permission denied while trying to connect to the Docker daemon socket`.**
On Linux, either use `sudo` or add yourself to the `docker` group
(`sudo usermod -aG docker $USER`, then log out and back in).

**`Could not find module Example` / Cryptol cannot find the file.** You are not
in the repository root, so the mount and `CRYPTOLPATH` point somewhere else.
`run-saw.sh` checks for this and refuses to start. Also remember the path you
type at the SAW prompt is the path *inside* the container.

**Permission denied writing `outputs/isabelle`.** Your host UID does not match
the container's `saw` user. Re-run as:

```bash
SAW_USER="$(id -u):$(id -g)" ./saw/run-saw.sh saw/extract_isabelle.saw
```

Record that you needed this — it is a real reproducibility difference between
our machines, and exactly the sort of thing the project is meant to document.

**`write_isabelle_cryptol_modules` is not in scope.** You forgot
`enable_experimental`, or it ran in a different session. Every fresh SAW
session needs it again.

**The output directory does not exist.** `run-saw.sh` creates
`outputs/isabelle` and `outputs/rocq` before starting the container. If you are
running docker by hand, `mkdir -p outputs/isabelle` first.

**Line endings.** If git on Windows converted `saw/run-saw.sh` to CRLF, Bash
fails with `bad interpreter`. The repository's `.gitattributes` prevents this;
if you hit it anyway, run `dos2unix saw/run-saw.sh`.
