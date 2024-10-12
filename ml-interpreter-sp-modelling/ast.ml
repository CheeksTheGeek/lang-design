(* ast.ml *)
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
  | List of expr list (* new: list *)
  | Index of expr * expr (* new: indexing *)
  | Add of expr * expr (* addition *)
  | Sub of expr * expr (* subtraction *)
  | Mul of expr * expr  (* multiplication *)
  | Div of expr * expr (* division *)
  | Eq of expr * expr (* equal *)
  | Lt of expr * expr (* less than *)
  | Gt of expr * expr (* greater than *)
  | LogisticRegression of expr * expr (* features, labels *)
  | PredictLogistic of expr * expr     (* model, input *)
  | KMeans of expr * expr              (* data, number of clusters *)
  | GetClusters of expr                (* get clusters from KMeans result *)
