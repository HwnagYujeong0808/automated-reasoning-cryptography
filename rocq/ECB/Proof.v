From Stdlib Require Import Strings.String.
#[local] Set Warnings "-stdlib-vector".
From Stdlib Require Import Vectors.Vector.

From CryptolToRocq Require Import SAWCoreScaffolding.
From CryptolToRocq Require Import SAWCoreVectorsAsRocqVectors.
From CryptolToRocq Require Import SAWCorePrelude.
From CryptolToRocq Require Import CryptolPrimitivesForSAWCore.

From ECB Require Import Wrapper.

Open Scope string_scope.

Section ECB.
  Variable Key: Type. Context `{Inhabited Key}.
  Variable Block: Type. Context `{Inhabited Block}.

  Variable params:
    RecordTypeCons "decipher" (Key -> Block -> Block)
      (RecordTypeCons "encipher" (Key -> Block -> Block)
        RecordTypeNil).

  Local Definition D: Key -> Block -> Block :=
    recordHead params.
  Local Definition E: Key -> Block -> Block :=
    recordHead (recordTail params).
  
  Hypothesis Hdeciphers: forall k b, D k (E k b) = b.

  Theorem ecb_decrypts (m: nat) (k: Key) (pt: Vec m Block) :
    decrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) params k
      (encrypt Key Block (CryptolPrimitivesForSAWCore.TCNum m) params k pt)
    = pt.
  Proof.
    unfold decrypt, encrypt, Wrapper.map.
    simpl CryptolPrimitivesForSAWCore.seqMap.
    unfold SAWCorePrelude.map.
    induction pt as [| h m t IH]; [reflexivity|].
    simpl. f_equal.
      - apply Hdeciphers.
      - exact IH.
  Qed.
End ECB.
  