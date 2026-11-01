From Stdlib Require Import Strings.String.
#[local] Set Warnings "-stdlib-vector".
From Stdlib Require Import Vectors.Vector.

From CryptolToRocq Require Import SAWCoreScaffolding.
From CryptolToRocq Require Import SAWCoreVectorsAsRocqVectors.
From CryptolToRocq Require Import SAWCorePrelude.
From CryptolToRocq Require Import CryptolPrimitivesForSAWCore.

From CryptolToRocq Require SAWCoreBitvectors.

From ECB Require Bool.
From CBC Require Import Wrapper.
From CBC Require Import Proof.

Open Scope string_scope.

Section CBCbool.
  Variable Key: Type. Context `{Inhabited Key}.
  Variable Block: Type. Context `{Inhabited Block}.

  Variable params:
    RecordTypeCons "decipher" (Key -> Block -> Block)
      (RecordTypeCons "encipher" (Key -> Block -> Block)
        RecordTypeNil).

  Variable pl pl1: CryptolPrimitivesForSAWCore.PLogic Block.
  Variable pe: CryptolPrimitivesForSAWCore.PEq Block.

  Local Notation xor := (CryptolPrimitivesForSAWCore.ecXor Block pl).

  Hypothesis Heq_refl:
    forall b, CryptolPrimitivesForSAWCore.ecEq Block pe b b = true.

  Hypothesis Hdeciphers:
    forall k b,
      recordHead params k
        (recordHead (recordTail params) k b) = b.

  Hypothesis Hxor: forall a b, xor (xor a b) b = a.

  Theorem decrypts_true (m: nat) (k: Key) (iv: Block) (pt: Vec m Block) :
    decrypts Key Block (CryptolPrimitivesForSAWCore.TCNum m) pl pl1
      (CryptolPrimitivesForSAWCore.PFin_TCNum m) pe params k iv pt
    = true.
  Proof.
    unfold decrypts.
    rewrite (cbc_decrypts Key Block params pl pl Hdeciphers Hxor m k iv pt).
    unfold
      CryptolPrimitivesForSAWCore.ecEq,
      CryptolPrimitivesForSAWCore.PEqSeq; simpl.
    apply Bool.vecEq_refl'. exact Heq_refl.
  Qed.

  Theorem deciphers_true (k: Key) (b: Block) :
    deciphers Key Block pl pl1 pe params k b = true.
  Proof.
    unfold deciphers. rewrite Hdeciphers. apply Heq_refl.
  Qed.

  Theorem xor_cancels_true (a b: Block) :
    xor_cancels Key Block pl pl1 pe params a b = true.
  Proof.
    unfold xor_cancels. rewrite Hxor. apply Heq_refl.
  Qed.
End CBCbool.

(** For `[w]`-bit blocks `(^)` needs no hypothesis: Rocq discharges it. *)
Section CBCword.
  Variable Key: Type. Context `{Inhabited Key}.
  Variable w: nat.
  Local Notation Block := (Vec w bool).
  Local Notation pw := (CryptolPrimitivesForSAWCore.PLogicWord w).

  Lemma xor_cancels_word (a b: Block) :
    CryptolPrimitivesForSAWCore.ecXor Block pw
      (CryptolPrimitivesForSAWCore.ecXor Block pw a b) b = a.
  Proof.
    change (SAWCorePrelude.bvXor w (SAWCorePrelude.bvXor w a b) b = a).
    rewrite <- SAWCoreBitvectors.bvXor_assoc, SAWCoreBitvectors.bvXor_same.
    apply SAWCoreBitvectors.bvXor_zero.
  Qed.

  Variable params:
    RecordTypeCons "decipher" (Key -> Block -> Block)
      (RecordTypeCons "encipher" (Key -> Block -> Block)
        RecordTypeNil).

  Hypothesis Hdeciphers:
    forall k b,
      recordHead params k
        (recordHead (recordTail params) k b) = b.

  Theorem decrypts_word (m: nat) (k: Key) (iv: Block) (pt: Vec m Block) :
    decrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) pw pw params k iv
      (encrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) pw pw params k iv pt)
    = pt.
  Proof.
    exact (cbc_decrypts Key Block params pw pw Hdeciphers xor_cancels_word m k iv pt).
  Qed.
End CBCword.

(** "Axioms: error : forall a, Inhabited a -> string -> a" *)
Print Assumptions decrypts_true.
Print Assumptions decrypts_word.
