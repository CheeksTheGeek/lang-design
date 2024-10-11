type expr =
  | Bool of bool
  | Int of int
  | Float of float
  | Var of string
  | Let of string * expr * expr 
  | If of expr * expr * expr (* if-then-else *)
  | Fun of string * expr (* lambda abstraction *)
  | App of expr * expr (* function application *)
  | Flip of expr (* flip: Bernoulli distribution *)
  | Uniform of expr * expr (* lower, upper *)
  | Gaussian of expr * expr (* mean, std *)
  | Add of expr * expr (* addition *)
  | Sub of expr * expr (* subtraction *)
  | Mul of expr * expr  (* multiplication *)
  | Div of expr * expr (* division *)
  | Eq of expr * expr (* equal *)
  | Lt of expr * expr (* less than *)
  | Gt of expr * expr (* greater than *)