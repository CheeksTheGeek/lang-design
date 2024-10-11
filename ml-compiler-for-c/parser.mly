%{
  open Ast
%}

%token <int>         INT_LIT
%token <float>       FLOAT_LIT
%token <char>        CHAR_LIT
%token <string>      STRING_LIT
%token <string>      IDENT
%token               INT FLOAT CHAR VOID
%token               IF ELSE WHILE FOR DO RETURN BREAK CONTINUE
%token               PLUS MINUS STAR SLASH PERCENT
%token               EQ EQEQ NEQ LT LE GT GE
%token               ANDAND OROR NOT AND OR XOR
%token               SEMI COMMA
%token               LPAREN RPAREN LBRACE RBRACE
%token               EOF

%start program
%type <Ast.program> program

%%

program:
  decl_list EOF { $1 }

decl_list:
  | /* empty */                  { [] }
  | decl_list decl SEMI          { $1 @ [$2] }
  | decl_list func_decl          { $1 @ [$2] }

decl:
  | type_spec IDENT var_decl_tail {
      match $3 with
      | None -> VarDecl($1, $2, None)
      | Some expr -> VarDecl($1, $2, Some expr)
    }

func_decl:
  | type_spec IDENT LPAREN param_list RPAREN compound_stmt {
      FuncDecl($1, $2, $4, $6)
    }

var_decl_tail:
  | /* empty */                  { None }
  | EQ expr                      { Some $2 }

type_spec:
  | INT                          { TInt }
  | FLOAT                        { TFloat }
  | CHAR                         { TChar }
  | VOID                         { TVoid }

param_list:
  | /* empty */                  { [] }
  | param                        { [$1] }
  | param_list COMMA param       { $1 @ [$3] }

param:
  | type_spec IDENT              { ($1, $2) }

compound_stmt:
  | LBRACE stmt_or_decl_list RBRACE { Block($2) }

stmt_or_decl_list:
  | /* empty */                  { [] }
  | stmt_or_decl_list stmt_or_decl { $1 @ [$2] }

stmt_or_decl:
  | stmt                         { Stmt($1) }
  | decl SEMI                    { Decl($1) }

stmt:
  | expr_stmt              { $1 }
  | compound_stmt          { $1 }
  | selection_stmt         { $1 }
  | iteration_stmt         { $1 }
  | jump_stmt              { $1 }

expr_stmt:
  | SEMI                         { Expr(IntLit(0)) }
  | expr SEMI                    { Expr($1) }

selection_stmt:
  | IF LPAREN expr RPAREN stmt {
      If($3, $5, None)
    }
  | IF LPAREN expr RPAREN stmt ELSE stmt {
      If($3, $5, Some $7)
    }

iteration_stmt:
  | WHILE LPAREN expr RPAREN stmt {
      While($3, $5)
    }
  | FOR LPAREN expr_opt SEMI expr_opt SEMI expr_opt RPAREN stmt {
      For($3, $5, $7, $9)
    }

jump_stmt:
  | RETURN SEMI                  { Return(None) }
  | RETURN expr SEMI             { Return(Some $2) }
  | BREAK SEMI                   { Break }
  | CONTINUE SEMI                { Continue }

expr_opt:
  | /* empty */                  { None }
  | expr                         { Some $1 }

expr:
  | assignment_expr             { $1 }

assignment_expr:
  | logical_or_expr              { $1 }
  | unary_expr EQ assignment_expr     { Assign($1, $3) }

logical_or_expr:
  | logical_and_expr            { $1 }
  | logical_or_expr OROR logical_and_expr {
      BinOp(Or, $1, $3)
    }

logical_and_expr:
  | equality_expr              { $1 }
  | logical_and_expr ANDAND equality_expr {
      BinOp(And, $1, $3)
    }

equality_expr:
  | relational_expr            { $1 }
  | equality_expr EQEQ relational_expr {
      BinOp(Eq, $1, $3)
    }
  | equality_expr NEQ relational_expr {
      BinOp(Neq, $1, $3)
    }

relational_expr:
  | additive_expr              { $1 }
  | relational_expr LT additive_expr {
      BinOp(Lt, $1, $3)
    }
  | relational_expr GT additive_expr {
      BinOp(Gt, $1, $3)
    }
  | relational_expr LE additive_expr {
      BinOp(Le, $1, $3)
    }
  | relational_expr GE additive_expr {
      BinOp(Ge, $1, $3)
    }

additive_expr:
  | multiplicative_expr        { $1 }
  | additive_expr PLUS multiplicative_expr {
      BinOp(Add, $1, $3)
    }
  | additive_expr MINUS multiplicative_expr {
      BinOp(Sub, $1, $3)
    }

multiplicative_expr:
  | unary_expr                 { $1 }
  | multiplicative_expr STAR unary_expr {
      BinOp(Mul, $1, $3)
    }
  | multiplicative_expr SLASH unary_expr {
      BinOp(Div, $1, $3)
    }
  | multiplicative_expr PERCENT unary_expr {
      BinOp(Mod, $1, $3)
    }

unary_expr:
  | primary_expr               { $1 }
  | MINUS unary_expr {
      UnOp(Neg, $2)
    }
  | NOT unary_expr {
      UnOp(Not, $2)
    }

primary_expr:
  | IDENT {
      Var($1)
    }
  | IDENT LPAREN argument_expr_list_opt RPAREN {
      Call($1, $3)
    }
  | INT_LIT {
      IntLit($1)
    }
  | FLOAT_LIT {
      FloatLit($1)
    }
  | CHAR_LIT {
      CharLit($1)
    }
  | STRING_LIT {
      StringLit($1)
    }
  | LPAREN expr RPAREN {
      $2
    }

argument_expr_list_opt:
  | /* empty */                  { [] }
  | argument_expr_list           { $1 }

argument_expr_list:
  | assignment_expr              { [$1] }
  | argument_expr_list COMMA assignment_expr {
      $1 @ [$3]
    }
