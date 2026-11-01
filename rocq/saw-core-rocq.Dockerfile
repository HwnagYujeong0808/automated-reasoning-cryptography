FROM rocq/rocq-prover:9.1.1

RUN opam install -y coq=9.1.1 \
    && opam pin -y coq-bits https://github.com/rocq-community/bits.git#f50fc3e5f1eabcb0b0b94c8d25f75e61a255c2ba \
    && opam pin -y coq-flocq https://gitlab.inria.fr/flocq/flocq.git#27143972fc1dc96e281626d5194b5b371f05db80
