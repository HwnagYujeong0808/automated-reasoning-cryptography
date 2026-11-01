From Stdlib Require Import Strings.String.
#[local] Set Warnings "-stdlib-vector".
From Stdlib Require Import Vectors.Vector.

From CryptolToRocq Require Import SAWCoreScaffolding.
From CryptolToRocq Require Import SAWCoreVectorsAsRocqVectors.
From CryptolToRocq Require Import SAWCorePrelude.
From CryptolToRocq Require Import CryptolPrimitivesForSAWCore.

From ECB Require Import Wrapper.
From ECB Require Import Proof.

Open Scope string_scope.

Lemma vecEq_refl'
  (A: Type) `{Inhabited A}
  (eq: A -> A -> bool) (Hr: forall a, eq a a = true)
  (n: nat) (x: Vec n A) :
    SAWCorePrelude.vecEq n A eq x x = true.
Proof.
  induction x as [| h m t IH]; [reflexivity|].
  unfold
    SAWCorePrelude.vecEq,
    SAWCorePrelude.zipWith,
    SAWCorePrelude.sawAt in *.
  simpl. rewrite Hr. exact IH.
Qed.

Section ECBbool.
  Variable Key: Type. Context `{Inhabited Key}.
  Variable Block: Type. Context `{Inhabited Block}.

  Variable params:
    RecordTypeCons "decipher" (Key -> Block -> Block)
      (RecordTypeCons "encipher" (Key -> Block -> Block)
        RecordTypeNil).

  Variable pe: CryptolPrimitivesForSAWCore.PEq Block.

  Hypothesis Heq_refl:
    forall b, CryptolPrimitivesForSAWCore.ecEq Block pe b b = true.

  Hypothesis Hdeciphers:
    forall k b,
      recordHead params k
        (recordHead (recordTail params) k b) = b.

  Theorem decrypts_true (m: nat) (k: Key) (pt: Vec m Block) :
    decrypts Key Block (CryptolPrimitivesForSAWCore.TCNum m)
      (CryptolPrimitivesForSAWCore.PFin_TCNum m) pe params k pt
    = true.
  Proof.
    unfold decrypts.
    rewrite (ecb_decrypts Key Block params Hdeciphers m k pt).
    unfold
      CryptolPrimitivesForSAWCore.ecEq,
      CryptolPrimitivesForSAWCore.PEqSeq; simpl.
    apply vecEq_refl'. exact Heq_refl.
  Qed.

  Theorem deciphers_true (k: Key) (b: Block) :
    deciphers Key Block pe params k b = true.
  Proof.
    unfold deciphers. rewrite Hdeciphers. apply Heq_refl.
  Qed.
End ECBbool.

(** "Axioms: error : forall a, Inhabited a -> string -> a" *)
Print Assumptions decrypts_true.