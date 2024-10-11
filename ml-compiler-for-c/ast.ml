type identifier = string

type typ =
  | TInt
  | TFloat
  | TChar
  | TVoid

type binop =
  | Add | Sub | Mul | Div | Mod
  | Lt | Le | Gt | Ge | Eq | Neq
  | And | Or

type unop =
  | Neg
  | Not

type expr =
  | IntLit    of int
  | FloatLit  of float
  | CharLit   of char
  | StringLit of string
  | Var       of identifier
  | BinOp     of binop * expr * expr
  | UnOp      of unop * expr
  | Call      of identifier * expr list
  | Assign    of expr * expr  (* Added for assignments *)

type stmt =
  | Expr      of expr
  | Return    of expr option
  | If        of expr * stmt * stmt option
  | While     of expr * stmt
  | For       of expr option * expr option * expr option * stmt
  | Block     of stmt_or_decl list
  | Break
  | Continue

and stmt_or_decl =
  | Stmt of stmt
  | Decl of decl

and decl =
  | VarDecl    of typ * identifier * expr option
  | FuncDecl   of typ * identifier * (typ * identifier) list * stmt

type program = decl list

type reg = X0 | X1 | X2 | X3 | X4 | X5 | X6 | X7 | X8 | X9 | X10 | X11 | X12 | X13 | X14 | X15

type asm_instruction =
  | Mov of reg * reg
  | Add of reg * reg * reg
  | Sub of reg * reg * reg
  | Mul of reg * reg * reg
  | Div of reg * reg * reg
  | Ret
