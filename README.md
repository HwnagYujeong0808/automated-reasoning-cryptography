# Automated Reasoning for Cryptography

This repository contains the work of the University at Albany INSuRE+E team for the **Automated Reasoning for Cryptography** project.

## Project Overview

The goal of this project is to explore formal verification of cryptographic specifications using **Cryptol**, **SAW (Software Analysis Workbench)**, and interactive proof assistants.

Our primary workflow is:

**Cryptol Specification → SAW → Rocq / Isabelle → Formal Verification**

The project investigates how cryptographic specifications can be extracted into proof assistants and formally validated, as well as the current limitations of this workflow.

## Tools

- **Cryptol** — Cryptographic specification language
- **SAW** — Software Analysis Workbench for analysis and verification
- **Rocq** — Proof assistant for formal verification
- **Isabelle** — Interactive theorem prover and automated reasoning environment
- **Docker** — Reproducible development environment

## Repository Structure

- `examples/` — Cryptol examples
- `saw/` — SAW scripts and experiments
- `rocq/` — Rocq extraction and proofs
- `isabelle/` — Isabelle extraction and proofs
- `docs/` — Setup guides and project documentation
- `results/` — Experimental results and observations

## Current Work

The team is currently:

1. Learning Cryptol and SAW
2. Testing Cryptol–SAW integration
3. Reproducing Cryptol-to-Isabelle and Cryptol-to-Rocq extraction examples
4. Evaluating Rocq and Isabelle for the project
5. Documenting extraction limitations and reproducibility issues

## Initial Example

The initial experiment uses a simple Cryptol module containing arithmetic properties such as:

- Addition associativity
- Addition commutativity
- Left distributivity
- Right distributivity

The module is loaded into SAW and extracted into a proof-assistant representation.

## Known Limitations

Current extraction workflows may have limitations involving:

- Recursive functions
- Parameterized modules
- Infinite/stream types
- Proof-assistant-specific translation requirements

These limitations will be investigated and documented throughout the project.

## Team

**University at Albany — INSuRE+E Team 1**

**Problem Mentor:** Matt Benke  
**Faculty Advisor:** Dr. Sanjay Goel
