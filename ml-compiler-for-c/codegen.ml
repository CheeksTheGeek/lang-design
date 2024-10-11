(* codegen.ml *)

open Ast

let string_of_reg = function
  | X0 -> "w0" | X1 -> "w1" | X2 -> "w2" | X3 -> "w3"
  | X4 -> "w4" | X5 -> "w5" | X6 -> "w6" | X7 -> "w7"
  | X8 -> "w8" | X9 -> "w9" | X10 -> "w10" | X11 -> "w11"
  | X12 -> "w12" | X13 -> "w13" | X14 -> "w14" | X15 -> "w15"

(* Variable stack offset mappings *)
let var_map = Hashtbl.create 10
let var_offset = ref 0
let label_count = ref 0

let new_label () =
  let label = Printf.sprintf "LBB0_%d" !label_count in
  incr label_count;
  label

let rec codegen_expr = function
  | IntLit(i) -> Printf.sprintf "  mov %s, #%d" (string_of_reg X8) i  (* Use w8 as working register *)
  | Var(id) ->
      if Hashtbl.mem var_map id then
        let offset = Hashtbl.find var_map id in
        Printf.sprintf "  ldr %s, [sp, #%d]" (string_of_reg X8) offset
      else
        failwith ("Undefined variable: " ^ id)
  | Assign(Var(id), e2) ->
      let rhs_code = codegen_expr e2 in
      if Hashtbl.mem var_map id then
        let offset = Hashtbl.find var_map id in
        Printf.sprintf "%s\n  str %s, [sp, #%d]" rhs_code (string_of_reg X8) offset
      else
        failwith ("Undefined variable: " ^ id)
  | BinOp(op, e1, e2) ->
      let left_code = codegen_expr e1 in
      let save_left = Printf.sprintf "  mov %s, %s" (string_of_reg X9) (string_of_reg X8) in
      let right_code = codegen_expr e2 in
      let code = match op with
          | Add -> Printf.sprintf "  add %s, %s, %s" (string_of_reg X8) (string_of_reg X9) (string_of_reg X8)
          | Sub -> Printf.sprintf "  sub %s, %s, %s" (string_of_reg X8) (string_of_reg X9) (string_of_reg X8)
          | Gt  -> Printf.sprintf "  subs %s, %s, #10\n  cset %s, le" (string_of_reg X8) (string_of_reg X9) (string_of_reg X8)
          | Lt  -> Printf.sprintf "  subs %s, %s, #10\n  cset %s, lt" (string_of_reg X8) (string_of_reg X9) (string_of_reg X8)
          (* Add other operators as needed *)
          | _ -> failwith "Not implemented"
      in
      String.concat "\n" [left_code; save_left; right_code; code]
  | _ -> failwith "Not implemented"

let rec codegen_stmt stmt epilogue_label = match stmt with
  | Expr(e) -> codegen_expr e
  | Return(Some e) ->
      let expr_code = codegen_expr e in
      (* Store result in sp, #12, and return *)
      Printf.sprintf "%s\n  str %s, [sp, #12]\n  ldr w0, [sp, #12]\n  b %s" expr_code (string_of_reg X8) epilogue_label
  | Return(None) ->
      Printf.sprintf "  mov w0, #0\n  b %s" epilogue_label
  | If(cond, then_stmt, Some else_stmt) ->
      let cond_code = codegen_expr cond in
      let then_code = codegen_stmt then_stmt epilogue_label in
      let else_code = codegen_stmt else_stmt epilogue_label in
      let else_label = new_label () in
      let end_label = new_label () in
      Printf.sprintf "%s\n  tbnz %s, #0, %s\n%s\n  b %s\n%s:\n%s\n%s:" cond_code (string_of_reg X8) else_label then_code end_label else_label else_code end_label
  | If(cond, then_stmt, None) ->
      let cond_code = codegen_expr cond in
      let then_code = codegen_stmt then_stmt epilogue_label in
      let end_label = new_label () in
      Printf.sprintf "%s\n  tbnz %s, #0, %s\n%s\n%s:" cond_code (string_of_reg X8) end_label then_code end_label
  | Block(stmts) ->
      String.concat "\n" (List.map (fun s -> codegen_stmt_or_decl s epilogue_label) stmts)
  | _ -> failwith "Not implemented"

and codegen_stmt_or_decl sod epilogue_label = match sod with
  | Stmt(stmt) -> codegen_stmt stmt epilogue_label
  | Decl(decl) -> codegen_var_decl decl

and codegen_var_decl = function
  | VarDecl(_, id, Some expr) ->
      let expr_code = codegen_expr expr in
      Hashtbl.add var_map id !var_offset;
      var_offset := !var_offset + 4;
      Printf.sprintf "%s\n  str %s, [sp, #%d]" expr_code (string_of_reg X8) (Hashtbl.find var_map id)
  | VarDecl(_, id, None) ->
      Hashtbl.add var_map id !var_offset;
      var_offset := !var_offset + 4;
      ""
  | FuncDecl(_, _, _, _) -> failwith "Function declaration not expected in variable declaration"

let codegen_func typ id params body =
  var_offset := 0;
  Hashtbl.clear var_map;
  label_count := 0;
  let epilogue_label = "func_end" in
  let body_code = codegen_stmt body epilogue_label in
  let stack_size = (!var_offset + 15) / 16 * 16 in  (* Align to 16 bytes *)
  Printf.sprintf ".globl _%s\n_%s:\n  sub sp, sp, #%d\n  str wzr, [sp, #12]\n%s\n%s:\n  add sp, sp, #%d\n  ret" id id stack_size body_code epilogue_label stack_size

let codegen_decl = function
  | FuncDecl(typ, id, params, body) -> codegen_func typ id params body
  | VarDecl(typ, id, expr_opt) -> codegen_var_decl (VarDecl(typ, id, expr_opt))

let codegen_program decls =
  String.concat "\n" (List.map codegen_decl decls)
