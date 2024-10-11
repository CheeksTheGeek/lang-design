(* main.ml *)

open Ast
open Lexing
open Codegen
(* Helper function to print lexing errors *)
let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.fprintf outx "%s:%d:%d" pos.pos_fname pos.pos_lnum
    (pos.pos_cnum - pos.pos_bol + 1)

(* Function to parse a file and return the AST *)
let parse_with_error lexbuf =
  try
    Parser.program Lexer.token lexbuf
  with
  | Lexer.Lexing_error msg ->
    let pos = lexbuf.lex_curr_p in
    Printf.fprintf stderr "%s:%d:%d: Lexing error: %s\nCharacter: %c\n"
      pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)
      msg (Lexing.lexeme_char lexbuf 0);
    exit (-1)
  | Parsing.Parse_error ->
    let pos = lexbuf.lex_curr_p in
    Printf.fprintf stderr "%s:%d:%d: Syntax error\nToken: %s\n"
      pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)
      (Lexing.lexeme lexbuf);
    exit (-1)
  

(* Pretty-printing AST - simple representation *)
let rec string_of_expr = function
  | IntLit(i) -> string_of_int i
  | FloatLit(f) -> string_of_float f
  | CharLit(c) -> Printf.sprintf "'%c'" c
  | StringLit(s) -> Printf.sprintf "\"%s\"" s
  | Var(id) -> id
  | BinOp(op, e1, e2) ->
      Printf.sprintf "(%s %s %s)"
        (string_of_expr e1) (string_of_binop op) (string_of_expr e2)
  | UnOp(op, e) ->
      Printf.sprintf "(%s%s)" (string_of_unop op) (string_of_expr e)
  | Assign(e1, e2) ->
      Printf.sprintf "(%s = %s)" (string_of_expr e1) (string_of_expr e2)
  | Call(id, args) ->
      Printf.sprintf "%s(%s)" id (String.concat ", " (List.map string_of_expr args))
    

and string_of_binop = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Lt  -> "<"
  | Le  -> "<="
  | Gt  -> ">"
  | Ge  -> ">="
  | Eq  -> "=="
  | Neq -> "!="
  | And -> "&&"
  | Or  -> "||"

and string_of_unop = function
  | Neg -> "-"
  | Not -> "!"

let rec string_of_stmt = function
  | Expr(e) -> string_of_expr e ^ ";"
  | Return(None) -> "return;"
  | Return(Some e) -> Printf.sprintf "return %s;" (string_of_expr e)
  | If(cond, then_stmt, None) ->
      Printf.sprintf "if (%s) %s" (string_of_expr cond) (string_of_stmt then_stmt)
  | If(cond, then_stmt, Some else_stmt) ->
      Printf.sprintf "if (%s) %s else %s"
        (string_of_expr cond) (string_of_stmt then_stmt) (string_of_stmt else_stmt)
  | While(cond, stmt) ->
      Printf.sprintf "while (%s) %s" (string_of_expr cond) (string_of_stmt stmt)
  | For(init, cond, step, stmt) ->
      Printf.sprintf "for (%s; %s; %s) %s"
        (string_of_expr_opt init) (string_of_expr_opt cond) (string_of_expr_opt step)
        (string_of_stmt stmt)
  | Block(stmts) ->
      Printf.sprintf "{\n%s\n}" (String.concat "\n" (List.map string_of_stmt_or_decl stmts))
  | Break -> "break;"
  | Continue -> "continue;"

and string_of_stmt_or_decl = function
  | Stmt(stmt) -> string_of_stmt stmt
  | Decl(VarDecl(typ, id, None)) ->
      Printf.sprintf "%s %s;" (string_of_typ typ) id
  | Decl(VarDecl(typ, id, Some expr)) ->
      Printf.sprintf "%s %s = %s;" (string_of_typ typ) id (string_of_expr expr)
  | Decl(FuncDecl(typ, id, params, body)) ->
      let params_str = String.concat ", " (List.map (fun (t, n) -> Printf.sprintf "%s %s" (string_of_typ t) n) params) in
      Printf.sprintf "%s %s(%s) %s" (string_of_typ typ) id params_str (string_of_stmt body)

and string_of_typ = function
  | TInt -> "int"
  | TFloat -> "float"
  | TChar -> "char"
  | TVoid -> "void"

and string_of_expr_opt = function
  | None -> ""
  | Some e -> string_of_expr e

let rec string_of_decl = function
  | VarDecl(typ, id, None) ->
      Printf.sprintf "%s %s;" (string_of_typ typ) id
  | VarDecl(typ, id, Some expr) ->
      Printf.sprintf "%s %s = %s;" (string_of_typ typ) id (string_of_expr expr)
  | FuncDecl(typ, id, params, body) ->
      let params_str = String.concat ", " (List.map (fun (t, n) -> Printf.sprintf "%s %s" (string_of_typ t) n) params) in
      Printf.sprintf "%s %s(%s) %s" (string_of_typ typ) id params_str (string_of_stmt body)

(* Function to convert a program (list of declarations) into a string *)
let string_of_program decls =
  String.concat "\n" (List.map string_of_decl decls)


let () =
  if Array.length Sys.argv <> 2 then
    Printf.fprintf stderr "Usage: %s <source-file>\n" Sys.argv.(0)
  else
    let filename = Sys.argv.(1) in
    let in_channel = open_in filename in
    let lexbuf = Lexing.from_channel in_channel in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
    let ast = parse_with_error lexbuf in
    close_in in_channel;
    
    (* Generate and print AArch64 assembly *)
    let assembly = Codegen.codegen_program ast in
    Printf.printf "%s\n" assembly
