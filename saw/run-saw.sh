#!/usr/bin/env bash
#
# run-saw.sh - start the SAW 1.6 container with this repository mounted.
#
# Run from the REPOSITORY ROOT (WSL/Ubuntu or Linux, not PowerShell):
#
#     ./saw/run-saw.sh                            # interactive SAW REPL
#     ./saw/run-saw.sh saw/extract_isabelle.saw   # run a SAW script and exit
#
# This is a thin wrapper around the exact docker command given by the problem
# mentor; see docs/implementation-guide.md section 10. The repository is
# mounted at /home/saw/<repo-name> inside the container, so anything SAW
# writes under outputs/ also appears on the host.
#
# If extraction fails with a permission error when writing outputs/, your host
# UID does not match the container's "saw" user. Re-run as:
#
#     SAW_USER="$(id -u):$(id -g)" ./saw/run-saw.sh
#
# and record that you needed it in results/ (it is a reproducibility detail).

set -euo pipefail

IMAGE="${SAW_IMAGE:-ghcr.io/galoisinc/saw:1.6}"
CUSER="${SAW_USER:-saw}"
WD="/home/saw/$(basename "$PWD")"

if [ ! -f "examples/Example.cry" ]; then
  echo "error: run this script from the repository root (examples/Example.cry not found)." >&2
  exit 1
fi

mkdir -p outputs/isabelle outputs/rocq

exec docker run --rm -it \
  -u "$CUSER" \
  -v "$PWD:$WD" \
  -w "$WD" \
  -e "CRYPTOLPATH=$WD" \
  "$IMAGE" "$@"
