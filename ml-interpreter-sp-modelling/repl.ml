(* repl.ml *)

open Eval
open Ansi
let rec repl env =
  print_string (style_text RegText Yellow " > ");
  flush stdout;
  try
    let line = read_line () in
    if line = "exit" then print_endline (style_text RegText Cyan "Until next time 👋")
    else
      let lexbuf = Lexing.from_string line in
      let expr = Parser.main Lexer.read lexbuf in
      let result = eval env expr in
      (match result with
       | VBool b -> print_endline (string_of_bool b)
       | VInt i -> print_endline (string_of_int i)
       | VFloat f -> print_endline (string_of_float f)
       | VFun _ -> print_endline "<function>"
       | VPrimFun _ -> print_endline "<primitive function>");
      repl env
  with
  | Lexer.Error msg ->
      print_endline (style_text BoldText Red "Lexer error");
      repl env
  | Parsing.Parse_error ->
      print_endline (style_text BoldText Red "Parser error");
      repl env
  | Eval.RuntimeError msg ->
      print_endline (style_text BoldText Red "Runtime error");
      repl env
  | End_of_file -> ()
