open Ast
open Distributions

exception RuntimeError of string

type value =
  | VBool of bool
  | VInt of int
  | VFloat of float
  | VFun of string * expr * env
  | VPrimFun of (value -> value)
  | VModel of model                (* new: to store trained models *)
  | VList of value list
and model =
  | LogisticModel of float list    (* coefficients for logistic regression *)
  | KMeansModel of (float list) list  (* centroids *)
and env = (string * value) list

let sigmoid x = 1.0 /. (1.0 +. exp (-.x))
let train_logistic_regression features labels =
  (* Simplified gradient descent implementation *)
  let learning_rate = 0.1 in
  let epochs = 1000 in
  let n_samples = List.length (match labels with VList lst -> lst | _ -> raise (RuntimeError "Expected list of labels")) in
  let n_features = match features with
    | VList (VList f :: _) -> List.length f
    | _ -> raise (RuntimeError "Features must be a list of feature vectors")
  in
  let weights = Array.make n_features 0.0 in
  for epoch = 1 to epochs do
    for i = 0 to n_samples - 1 do
      let xi = match List.nth (match features with VList lst -> lst | _ -> raise (RuntimeError "Expected list of features")) i with
        | VList vals -> List.map (function VFloat f -> f | _ -> raise (RuntimeError "Expected float values in feature vectors")) vals
        | _ -> raise (RuntimeError "Expected list of floats for features")
      in
      let yi = match List.nth (match labels with VList lst -> lst | _ -> raise (RuntimeError "Expected list of labels")) i with
        | VFloat f -> f
        | VInt i -> float_of_int i
        | _ -> raise (RuntimeError "Expected numeric labels")
      in
      let linear_output = List.fold_left2 (fun acc w x -> acc +. w *. x) 0.0 (Array.to_list weights) xi in
      let prediction = sigmoid linear_output in
      let error = yi -. prediction in
      Array.iteri (fun j w -> weights.(j) <- w +. learning_rate *. error *. List.nth xi j) weights
    done
  done;
  LogisticModel (Array.to_list weights)

let predict_logistic_regression model input =
  match model with
  | LogisticModel weights ->
      let inputs = match input with
        | VList lst -> List.map (function VFloat f -> f | _ -> 0.0) lst
        | _ -> raise (RuntimeError "Input must be a list of features")
      in
      let linear_output = List.fold_left2 (fun acc w x -> acc +. w *. x) 0.0 weights inputs in
      let prob = sigmoid linear_output in
      VFloat prob
  | _ -> raise (RuntimeError "Expected a logistic regression model")

(* Helper functions for K-Means Clustering *)
let train_kmeans data k =
  (* Simplified K-Means implementation *)
  let max_iterations = 100 in
  let data_points = match data with
    | VList lst -> List.map (function
        | VList vals -> List.map (function VFloat f -> f | _ -> raise (RuntimeError "Expected float values in data points")) vals
        | _ -> raise (RuntimeError "Expected list of feature vectors")) lst
    | _ -> raise (RuntimeError "Data must be a list of feature vectors")
  in
  let n_samples = List.length data_points in
  let n_features = List.length (List.hd data_points) in
  (* Initialize centroids randomly *)
  let centroids = Array.init k (fun _ -> List.nth data_points (Random.int n_samples)) in
  let labels = Array.make n_samples 0 in
  for iter = 1 to max_iterations do
    (* Assign labels *)
    for i = 0 to n_samples - 1 do
      let distances = Array.map (fun centroid ->
        let sum = List.fold_left2 (fun acc xi ci -> acc +. (xi -. ci) ** 2.0) 0.0 (List.nth data_points i) centroid in
        sqrt sum) centroids in
      let min_index = snd (Array.fold_left (fun (min_dist, min_idx) dist ->
        if dist < min_dist then (dist, min_idx + 1) else (min_dist, min_idx + 1)) (infinity, -1) distances) in
      labels.(i) <- min_index
    done;
    (* Update centroids *)
    for j = 0 to k - 1 do
      let cluster_points = List.filteri (fun idx _ -> labels.(idx) = j) data_points in
      if cluster_points <> [] then
        centroids.(j) <- List.map (fun dim ->
          let sum = List.fold_left (fun acc point -> acc +. List.nth point dim) 0.0 cluster_points in
          sum /. float_of_int (List.length cluster_points)
        ) (List.init n_features (fun idx -> idx))
    done
  done;
  KMeansModel (Array.to_list centroids)

(* Utility function to filter list with index *)
let rec filteri f lst =
  let rec aux i = function
    | [] -> []
    | x::xs -> if f i x then x :: aux (i+1) xs else aux (i+1) xs
  in
  aux 0 lst


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
  | List exprs ->   (* new: evaluate list *)
      let vs = List.map (eval env) exprs in
      VList vs
  | Index (e_list, e_index) ->  (* new: evaluate indexing *)
      let v_list = eval env e_list in
      let v_index = eval env e_index in
      (match v_list, v_index with
       | VList vs, VInt i ->
           (try List.nth vs i
            with _ -> raise (RuntimeError "Index out of bounds"))
       | VList vs, VFloat f ->
           let i = int_of_float f in
           (try List.nth vs i
            with _ -> raise (RuntimeError "Index out of bounds"))
       | _, _ -> raise (RuntimeError "Expected list and integer in indexing"))
  | Add (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 +. v2)
       | VInt v1, VInt v2 -> VInt (v1 + v2)
       | VInt v1, VFloat v2 -> VFloat (float_of_int v1 +. v2)
       | VFloat v1, VInt v2 -> VFloat (v1 +. float_of_int v2)
       | _ -> raise (RuntimeError "Expected numbers in addition"))
  | Sub (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 -. v2)
       | VInt v1, VInt v2 -> VInt (v1 - v2)
       | VInt v1, VFloat v2 -> VFloat (float_of_int v1 -. v2)
       | VFloat v1, VInt v2 -> VFloat (v1 -. float_of_int v2)
       | _ -> raise (RuntimeError "Expected numbers in subtraction"))
  | Mul (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 *. v2)
       | VInt v1, VInt v2 -> VInt (v1 * v2)
       | VInt v1, VFloat v2 -> VFloat (float_of_int v1 *. v2)
       | VFloat v1, VInt v2 -> VFloat (v1 *. float_of_int v2)
       | _ -> raise (RuntimeError "Expected numbers in multiplication"))
  | Div (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VFloat (v1 /. v2)
       | VInt v1, VInt v2 -> VFloat (float_of_int v1 /. float_of_int v2)
       | VInt v1, VFloat v2 -> VFloat (float_of_int v1 /. v2)
       | VFloat v1, VInt v2 -> VFloat (v1 /. float_of_int v2)
       | _ -> raise (RuntimeError "Expected numbers in division"))
  | Eq (e1, e2) ->
      let v1 = eval env e1 in
      let v2 = eval env e2 in
      VBool (v1 = v2)
  | Lt (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VBool (v1 < v2)
       | VInt v1, VInt v2 -> VBool (v1 < v2)
       | VInt v1, VFloat v2 -> VBool (float_of_int v1 < v2)
       | VFloat v1, VInt v2 -> VBool (v1 < float_of_int v2)
       | _ -> raise (RuntimeError "Expected numbers in less than comparison"))
  | Gt (e1, e2) ->
      (match eval env e1, eval env e2 with
       | VFloat v1, VFloat v2 -> VBool (v1 > v2)
       | VInt v1, VInt v2 -> VBool (v1 > v2)
       | VInt v1, VFloat v2 -> VBool (float_of_int v1 > v2)
       | VFloat v1, VInt v2 -> VBool (v1 > float_of_int v2)
       | _ -> raise (RuntimeError "Expected numbers in greater than comparison"))
  | LogisticRegression (features_expr, labels_expr) ->
      let features = eval env features_expr in
      let labels = eval env labels_expr in
      let model = train_logistic_regression features labels in
      VModel model
  | PredictLogistic (model_expr, input_expr) ->
      let model_value = eval env model_expr in
      let input_value = eval env input_expr in
      (match model_value with
       | VModel model -> predict_logistic_regression model input_value
       | _ -> raise (RuntimeError "Expected a logistic regression model"))
  | KMeans (data_expr, k_expr) ->
      let data = eval env data_expr in
      let k_value = eval env k_expr in
      let k = match k_value with
        | VInt i -> i
        | VFloat f -> int_of_float f
        | _ -> raise (RuntimeError "KMeans: expected an integer for number of clusters")
      in
      let model = train_kmeans data k in
      VModel model
  | GetClusters model_expr ->
      let model_value = eval env model_expr in
      (match model_value with
       | VModel (KMeansModel centroids) ->
           VList (List.map (fun centroid -> VList (List.map (fun x -> VFloat x) centroid)) centroids)
       | _ -> raise (RuntimeError "Expected a KMeans model"))


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
  ("mean", VPrimFun (function   (* new: mean function *)
    | VList lst ->
        let sum = List.fold_left (fun acc v ->
          match v with
          | VFloat f -> acc +. f
          | VInt i -> acc +. float_of_int i
          | _ -> raise (RuntimeError "mean: list must contain numbers")) 0.0 lst in
        let len = float_of_int (List.length lst) in
        VFloat (sum /. len)
    | _ -> raise (RuntimeError "mean: expected a list")));
  ("sum", VPrimFun (function    (* new: sum function *)
    | VList lst ->
        let total = List.fold_left (fun acc v ->
          match v with
          | VFloat f -> acc +. f
          | VInt i -> acc +. float_of_int i
          | _ -> raise (RuntimeError "sum: list must contain numbers")) 0.0 lst in
        VFloat total
    | _ -> raise (RuntimeError "sum: expected a list")));
  ("linear_regression", VPrimFun (function  (* new: linear regression *)
    | VList x_list ->
        VPrimFun (function
          | VList y_list ->
              let n = List.length x_list in
              if n <> List.length y_list then
                raise (RuntimeError "linear_regression: x and y lists must have same length")
              else
                let x_values = List.map (function
                  | VFloat f -> f
                  | VInt i -> float_of_int i
                  | _ -> raise (RuntimeError "linear_regression: x list must contain numbers")) x_list in
                let y_values = List.map (function
                  | VFloat f -> f
                  | VInt i -> float_of_int i
                  | _ -> raise (RuntimeError "linear_regression: y list must contain numbers")) y_list in
                let sum_x = List.fold_left (+.) 0.0 x_values in
                let sum_y = List.fold_left (+.) 0.0 y_values in
                let sum_xx = List.fold_left (fun acc x -> acc +. x *. x) 0.0 x_values in
                let sum_xy = List.fold_left2 (fun acc x y -> acc +. x *. y) 0.0 x_values y_values in
                let n_f = float_of_int n in
                let denom = n_f *. sum_xx -. sum_x *. sum_x in
                if denom = 0.0 then
                  raise (RuntimeError "linear_regression: cannot compute coefficients (division by zero)")
                else
                  let m = (n_f *. sum_xy -. sum_x *. sum_y) /. denom in
                  let b = (sum_y -. m *. sum_x) /. n_f in
                  VList [VFloat m; VFloat b]
          | _ -> raise (RuntimeError "linear_regression: expected y list"))
    | _ -> raise (RuntimeError "linear_regression: expected x list")));
]
