open Ast
open Distributions

exception RuntimeError of string

type value =
  | VBool of bool
  | VInt of int
  | VFloat of float
  | VFun of string * expr * env
  | VPrimFun of (value -> value)
and env = (string * value) list

let rec eval (env : env) (e : expr) : value =
  match e with
  | Bool b -> VBool b
  | Int i -> VInt i
  | Float f -> VFloat f
  | Var x ->
      (try List.assoc x env
       with Not_found -> raise (RuntimeError ("Unbound variable: " ^ x)))
  | Let (x, e1, e2) ->
      let v1 = eval env e1 in
      eval ((x, v1) :: env) e2
  | If (e1, e2, e3) ->
      (match eval env e1 with
       | VBool true -> eval env e2
       | VBool false -> eval env e3
       | _ -> raise (RuntimeError "Expected boolean in if condition"))
  | Fun (x, e) -> VFun (x, e, env)
  | App (e1, e2) ->
      let v1 = eval env e1 in
      let v2 = eval env e2 in
      (match v1 with
       | VFun (x, body, env') -> eval ((x, v2) :: env') body
       | VPrimFun f -> f v2
       | _ -> raise (RuntimeError "Expected a function"))
  | Add (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 +. v2)
       | _ -> raise (RuntimeError "Expected floats in addition"))
  | Sub (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 -. v2)
       | _ -> raise (RuntimeError "Expected floats in subtraction"))
  | Mul (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 *. v2)
       | _ -> raise (RuntimeError "Expected floats in multiplication"))
  | Div (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 /. v2)
       | _ -> raise (RuntimeError "Expected floats in division"))
  | Eq (e1, e2) ->
      let v1 = eval env e1 in
      let v2 = eval env e2 in
      VBool (v1 = v2)
  | Lt (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VBool (v1 < v2)
       | _ -> raise (RuntimeError "Expected floats in less than comparison"))
  | Gt (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VBool (v1 > v2)
       | _ -> raise (RuntimeError "Expected floats in greater than comparison"))

(* Include the initial environment *)
let initial_env : env = [
  ("flip", VPrimFun (function
    | VFloat p -> VBool (flip p)
    | _ -> raise (RuntimeError "Expected a float in flip")));
  ("uniform", VPrimFun (function
    | VFloat a -> VPrimFun (function
        | VFloat b -> VFloat (uniform a b)
        | _ -> raise (RuntimeError "Expected a float in uniform"))
    | _ -> raise (RuntimeError "Expected a float in uniform")));
  ("gaussian", VPrimFun (function
    | VFloat mu -> VPrimFun (function
        | VFloat sigma -> VFloat (gaussian mu sigma)
        | _ -> raise (RuntimeError "Expected a float in gaussian"))
    | _ -> raise (RuntimeError "Expected a float in gaussian")));
]
