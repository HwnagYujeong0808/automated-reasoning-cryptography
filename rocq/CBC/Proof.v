From Stdlib Require Import Strings.String.
#[local] Set Warnings "-stdlib-vector".
From Stdlib Require Import Vectors.Vector.

From CryptolToRocq Require Import SAWCoreScaffolding.
From CryptolToRocq Require Import SAWCoreVectorsAsRocqVectors.
From CryptolToRocq Require Import SAWCorePrelude.
From CryptolToRocq Require Import CryptolPrimitivesForSAWCore.

From CBC Require Import Wrapper.

Open Scope string_scope.

Lemma gen_sawAt (A: Type) `{Inhabited A} (m: nat) (v: Vec m A) :
  gen m A (SAWCorePrelude.sawAt m A v) = v.
Proof.
  induction v as [| h m t IH]; [reflexivity|].
  exact (f_equal (Vector.cons A h m) IH).
Qed.

Lemma drop1_cons (A: Type) `{Inhabited A} (m: nat) (h: A) (t: Vec m A) :
  SAWCorePrelude.drop A 1 m (Vector.cons A h m t) = t.
Proof. exact (gen_sawAt A m t). Qed.

(** What `drop`{1} (scanl f z xs)` computes: the running states after `z`. *)
Section Scan.
  Variable A: Type.
  Variable B: Type. Context `{Inhabited B}.
  Variable f: B -> A -> B.

  Definition states (m: nat) (z: B) (xs: Vec m A) : Vec m B :=
    SAWCorePrelude.drop B 1 m (scanl A B m f z xs).

  Lemma states_cons (m: nat) (z: B) (x: A) (xs: Vec m A) :
    states (S m) z (Vector.cons A x m xs)
    = Vector.cons B (f z x) m (states m (f z x) xs).
  Proof.
    unfold states. simpl scanl. rewrite drop1_cons.
    destruct xs as [| x' m' xs']; simpl scanl; rewrite drop1_cons; reflexivity.
  Qed.
End Scan.

Section CBC.
  Variable Key: Type. Context `{Inhabited Key}.
  Variable Block: Type. Context `{Inhabited Block}.

  Variable params:
    RecordTypeCons "decipher" (Key -> Block -> Block)
      (RecordTypeCons "encipher" (Key -> Block -> Block)
        RecordTypeNil).
  Variable pl pl1: CryptolPrimitivesForSAWCore.PLogic Block.

  Local Definition D: Key -> Block -> Block :=
    recordHead params.
  Local Definition E: Key -> Block -> Block :=
    recordHead (recordTail params).
  Local Notation xor := (CryptolPrimitivesForSAWCore.ecXor Block pl).

  Hypothesis Hdeciphers: forall k b, D k (E k b) = b.
  Hypothesis Hxor: forall a b, xor (xor a b) b = a.

  Local Notation State :=
    (PairType Block (PairType Block UnitType)).

  (** One step of each scan: state = (previous ciphertext, plaintext). *)
  Local Definition estep (k: Key) (prev pt: Block) : Block :=
    E k (xor pt prev).
  Local Definition dstep (k: Key) (s: State) (ct: Block) : State :=
    PairValue Block (PairType Block UnitType) ct
      (PairValue Block UnitType (xor (D k ct) (SAWCorePrelude.Pair_fst Block _ s)) Unit).
  Local Definition plain (s: State) : Block :=
    SAWCorePrelude.Pair_fst Block _ (SAWCorePrelude.Pair_snd Block _ s).

  (** SAW's `map` on vectors: `gen` over `sawAt`. *)
  Local Definition plains (m: nat) (v: Vec m State) : Vec m Block :=
    gen m Block (fun i => plain (SAWCorePrelude.sawAt m State v i)).

  Local Lemma plains_cons (m: nat) (x: State) (xs: Vec m State) :
    plains (S m) (Vector.cons State x m xs)
    = Vector.cons Block (plain x) m (plains m xs).
  Proof. reflexivity. Qed.

  (** The chaining invariant: decryption tracks encryption's previous block. *)
  Lemma chain (k: Key) (m: nat) (pt: Vec m Block) :
    forall (prev: Block) (s: State),
      SAWCorePrelude.Pair_fst Block _ s = prev ->
      plains m
        (states Block State (dstep k) m s
           (states Block Block (estep k) m prev pt))
      = pt.
  Proof.
    induction pt as [| h m t IH]; intros prev s Hs; [reflexivity|].
    rewrite states_cons, states_cons, plains_cons. f_equal.
    - unfold plain, dstep. simpl. rewrite Hs.
      unfold estep. rewrite Hdeciphers. apply Hxor.
    - apply IH. reflexivity.
  Qed.

  (** `encrypt` really is CBC: C1 = E(P1 ^ IV), and C1 chains into the rest. *)
  Theorem cbc_encrypt_cons (m: nat) (k: Key) (iv h: Block) (t: Vec m Block) :
    encrypt Key Block (CryptolPrimitivesForSAWCore.TCNum (S m)) pl pl1 params k iv
      (Vector.cons Block h m t)
    = Vector.cons Block (E k (xor h iv)) m
        (encrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) pl pl1 params k
           (E k (xor h iv)) t).
  Proof. exact (states_cons Block Block (estep k) m iv h t). Qed.

  Theorem cbc_decrypts (m: nat) (k: Key) (iv: Block) (pt: Vec m Block) :
    decrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) pl pl1 params k iv
      (encrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) pl pl1 params k iv pt)
    = pt.
  Proof.
    exact (chain k m pt iv (PairValue Block _ iv (PairValue Block _ iv Unit)) eq_refl).
  Qed.
End CBC.
