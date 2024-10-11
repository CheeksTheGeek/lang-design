{
  open Parser
  exception Lexing_error of string
}

rule token = parse
  | [' ' '\t' '\n' '\r'] { token lexbuf } (* Skip whitespace *)
  | "//"                { single_line_comment lexbuf }
  | "/*"                { multi_line_comment lexbuf }
  | ['a'-'z' 'A'-'Z' '_' ] ['a'-'z' 'A'-'Z' '0'-'9' '_' ]* as id {
      match id with
      | "int"      -> INT
      | "float"    -> FLOAT
      | "char"     -> CHAR
      | "if"       -> IF
      | "else"     -> ELSE
      | "return"   -> RETURN
      | "while"    -> WHILE
      | "for"      -> FOR
      | "do"       -> DO
      | "break"    -> BREAK
      | "continue" -> CONTINUE
      | "void"     -> VOID
      | _          -> IDENT id
    }
  | ['0'-'9']+ as int_lit { INT_LIT (int_of_string int_lit) }
  | ['0'-'9']+ '.' ['0'-'9']* as float_lit { FLOAT_LIT (float_of_string float_lit) }
  | '"' [^ '"']* '"' as str_lit { STRING_LIT (String.sub str_lit 1 (String.length str_lit - 2)) }
  | '\'' [^ '\''] '\'' as char_lit { CHAR_LIT (String.sub char_lit 1 1).[0] }
  | "{"         { LBRACE }
  | "}"         { RBRACE }
  | "("         { LPAREN }
  | ")"         { RPAREN }
  | ";"         { SEMI }
  | ","         { COMMA }
  | "+"         { PLUS }
  | "-"         { MINUS }
  | "*"         { STAR }
  | "/"         { SLASH }
  | "="         { EQ }
  | "=="        { EQEQ }
  | "!="        { NEQ }
  | "<"         { LT }
  | "<="        { LE }
  | ">"         { GT }
  | ">="        { GE }
  | "&&"        { ANDAND }
  | "||"        { OROR }
  | "!"         { NOT }
  | "&"         { AND }
  | "|"         { OR }
  | "^"         { XOR }
  | "%"         { PERCENT }
  | eof         { EOF }
  | _           { raise (Lexing_error "Unexpected character") }

(* Handle single-line comments *)
and single_line_comment = parse
  | "\n" { token lexbuf }
  | _    { single_line_comment lexbuf }

(* Handle multi-line comments *)
and multi_line_comment = parse
  | "*/" { token lexbuf }
  | _    { multi_line_comment lexbuf }
