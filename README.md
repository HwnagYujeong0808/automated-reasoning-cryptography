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

```text
automated-reasoning-cryptography/
├── examples/       # Cryptol examples
├── saw/            # SAW scripts and experiments
├── rocq/           # Rocq extraction and proofs
├── isabelle/       # Isabelle extraction and proofs
├── docs/           # Setup guides and project documentation
└── results/        # Experimental results and observations
