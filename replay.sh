#!/usr/bin/env bash
#
# replay.sh - Cryptol -> SAW -> Rocq validation of ECB and CBC, end to end.
#
# From a clean clone on any Linux host with Docker (no TTY needed):
#
#     ./replay.sh
#
# Everything is logged to results/replay-<hostname>.log. Exits non-zero if a
# step fails, if extraction differs from the committed outputs/rocq, or if a
# proof rests on any axiom other than `error`.

set -euo pipefail
cd "$(dirname "$0")"

SAW_IMAGE=ghcr.io/galoisinc/saw:1.6
ROCQ_IMAGE=saw-core-rocq:9.1.1
OPAM_BIN=/home/rocq/.opam/4.14.2+flambda/bin
SAW_SCRIPT="$PWD/.cache/saw-script"
USERMAP="$(id -u):$(id -g)"   # host owner, so generated files stay ours on any UID
LOG="results/replay-$(hostname -s).log"
ROCQ_OUT="$(mktemp)"
trap 'rm -f "$ROCQ_OUT"' EXIT

exec > >(tee "$LOG") 2>&1

step() { printf '\n=== %s\n' "$*"; }

step "Environment"
date -u '+%Y-%m-%d %H:%M:%S UTC'
uname -sr
docker --version
echo "commit: $(git rev-parse HEAD)"

step "1/4 Images"
docker pull -q "$SAW_IMAGE"
docker image inspect "$ROCQ_IMAGE" >/dev/null 2>&1 \
  || docker build -t "$ROCQ_IMAGE" - < rocq/saw-core-rocq.Dockerfile
docker image inspect --format '{{index .RepoTags 0}} {{.Id}}' "$SAW_IMAGE" "$ROCQ_IMAGE"

step "2/4 SAW scaffolding (saw-core-rocq, v1.6)"
[ -d "$SAW_SCRIPT" ] || git clone -q --depth 1 --branch v1.6 \
  https://github.com/GaloisInc/saw-script "$SAW_SCRIPT"
mkdir -p "$SAW_SCRIPT/saw-core-rocq/rocq/generated/CryptolToRocq"
docker run --rm -u "$USERMAP" -v "$SAW_SCRIPT:/work" -w /work "$SAW_IMAGE" \
  saw-core-rocq/saw/generate_scaffolding.saw

step "3/4 Extract ECB and CBC wrappers"
docker run --rm -u "$USERMAP" -v "$PWD:/work" -w /work \
  -e CRYPTOLPATH=/work/examples "$SAW_IMAGE" saw/extract_rocq.saw
git diff --exit-code --stat -- outputs/rocq/ECB outputs/rocq/CBC
echo "Extraction matches committed outputs/rocq."

step "4/4 Compile saw-core, wrappers and proofs"
# saw-core-rocq's own Makefile insists on finding `saw`, so generate one instead.
# The image's `opam exec` entrypoint only works as uid 1000, so bypass it.
mkdir -p rocq/saw-core
docker run --rm -u "$USERMAP" -e HOME=/tmp -e "PATH=$OPAM_BIN:/usr/bin:/bin" \
  --entrypoint sh \
  -v "$PWD:/work" -v "$SAW_SCRIPT/saw-core-rocq/rocq:/work/rocq/saw-core" \
  -w /work/rocq "$ROCQ_IMAGE" -ec '
    echo "ROCQ compile saw-core (quiet)"
    (cd saw-core && rocq makefile -f _RocqProject -o Makefile.rocq \
      && make -j"$(nproc)" -f Makefile.rocq) >/tmp/saw-core.log 2>&1 \
      || { tail -30 /tmp/saw-core.log; exit 1; }
    rocq makefile -f _RocqProject -o Makefile.rocq 2>/dev/null
    make -f Makefile.rocq' | tee "$ROCQ_OUT"

step "Result"
# Print Assumptions runs once per mode; `error` must be all either one rests on.
[ "$(grep -c '^Axioms:' "$ROCQ_OUT")" = 2 ]
extra="$(awk '/^ROCQ/{f=0} f; /^Axioms:/{f=1}' "$ROCQ_OUT" | grep -v '^error : ' || true)"
[ -z "$extra" ] || { printf 'Unexpected axioms:\n%s\n' "$extra"; exit 1; }
sha256sum outputs/rocq/ECB/Wrapper.v outputs/rocq/CBC/Wrapper.v
echo "ECB and CBC validated in ${SECONDS}s; only axiom: error."
