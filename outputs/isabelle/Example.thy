theory "Example"
imports "Cryptol.Cryptol"
begin

context includes cryptol_translation_syntax begin
cryptol_definition add_assoc_l :: "{'a} ((Eq 'a,Ring 'a) =?> ('a \<Rightarrow> ('a \<Rightarrow> ('a \<Rightarrow> Bool))))" where
"add_assoc_l x y z \<equiv> (x +`{'a} (y +`{'a} z)) ==`{'a} ((x +`{'a} y) +`{'a} z)"

cryptol_definition add_comm :: "{'a} ((Eq 'a,Ring 'a) =?> ('a \<Rightarrow> ('a \<Rightarrow> Bool)))" where
"add_comm x y \<equiv> (x +`{'a} y) ==`{'a} (y +`{'a} x)"

cryptol_definition dist_l :: "{'a} ((Eq 'a,Ring 'a) =?> ('a \<Rightarrow> ('a \<Rightarrow> ('a \<Rightarrow> Bool))))" where
"dist_l x y z \<equiv> (x *`{'a} (y +`{'a} z)) ==`{'a} ((x *`{'a} y) +`{'a} (x *`{'a} z))"

cryptol_definition dist_r :: "{'a} ((Eq 'a,Ring 'a) =?> ('a \<Rightarrow> ('a \<Rightarrow> ('a \<Rightarrow> Bool))))" where
"dist_r x y z \<equiv> ((x +`{'a} y) *`{'a} z) ==`{'a} ((x *`{'a} z) +`{'a} (y *`{'a} z))"

end
end
