(* main.ml *)
open Ansi
let () =
  Random.self_init ();
  print_endline (style_text RegText Cyan " REPL for Tansh: Turing Approximation for Non-deterministic Stochastic Heuristics");
  print_endline (style_text RegText Cyan " Type 'exit' to quit.");
  Repl.repl Eval.initial_env
