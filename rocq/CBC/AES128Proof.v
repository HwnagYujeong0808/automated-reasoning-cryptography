(** CBC multi-block plaintext recovery with the real (adapted) AES-128 as the
    block cipher. The generic CBC proof (Proof.v, Bool.v) takes the cipher as a
    parameter; here we supply the AES-128 functions extracted from
    examples/AESAdapted.cry, and state AES's own block recovery as the single
    assumption. *)

From Stdlib Require Import Strings.String.
#[local] Set Warnings "-stdlib-vector".
From Stdlib Require Import Vectors.Vector.

From CryptolToRocq Require Import SAWCoreScaffolding.
From CryptolToRocq Require Import SAWCoreVectorsAsRocqVectors.
From CryptolToRocq Require Import SAWCorePrelude.
From CryptolToRocq Require Import CryptolPrimitivesForSAWCore.

From CBC Require Import Wrapper.
From CBC Require Import Bool.
From CBC Require AESAdapted.

Open Scope string_scope.

Local Notation Word := (Vec 128 bool).

(** AES-128 as CBC's cipher parameter. AES's functions take (message, key). *)
Definition aesParams :
  RecordTypeCons "decipher" (Word -> Word -> Word)
    (RecordTypeCons "encipher" (Word -> Word -> Word) RecordTypeNil) :=
  RecordCons "decipher"
    (fun k b =>
       AESAdapted.aesDecrypt
         (PairValue Word (PairType Word UnitType) b
            (PairValue Word UnitType k Unit)))
    (RecordCons "encipher"
       (fun k b =>
          AESAdapted.aesEncrypt
            (PairValue Word (PairType Word UnitType) b
               (PairValue Word UnitType k Unit)))
       RecordNil).

(** AES-128 block plaintext recovery: decrypting an encrypted block gives the
    block back. This is the assumption to be discharged (it is currently only
    checked in SAW, not proved in Rocq). *)
Definition AESBlockRecovery : Prop :=
  forall (k b: Word),
    recordHead aesParams k (recordHead (recordTail aesParams) k b) = b.

(** Multi-block CBC plaintext recovery for AES-128, given block recovery. *)
Theorem aes128_cbc_decrypts (Hrec: AESBlockRecovery)
    (m: nat) (k iv: Word) (pt: Vec m Word) :
  decrypt Word Word (CryptolPrimitivesForSAWCore.TCNum m)
    (CryptolPrimitivesForSAWCore.PLogicWord 128)
    (CryptolPrimitivesForSAWCore.PLogicWord 128) aesParams k iv
    (encrypt Word Word (CryptolPrimitivesForSAWCore.TCNum m)
       (CryptolPrimitivesForSAWCore.PLogicWord 128)
       (CryptolPrimitivesForSAWCore.PLogicWord 128) aesParams k iv pt)
  = pt.
Proof.
  exact (decrypts_word Word 128 aesParams Hrec m k iv pt).
Qed.

(** Expected: `error` only, plus none from the CBC proof itself. *)
Print Assumptions aes128_cbc_decrypts.
