module Parser
  ( parseExpr
  , parseExprs
  ) where

import Types (LispVal(..))
import Text.Parsec
import Text.Parsec.String (Parser)
import Control.Monad (void)

-- | Top-level parse function for a single expression.
parseExpr :: String -> Either ParseError LispVal
parseExpr = parse (whiteSpace >> lispVal <* eof) "lisp"

-- | Parse multiple Lisp expressions from a string.
parseExprs :: String -> Either ParseError [LispVal]
parseExprs = parse (whiteSpace >> many (lispVal <* whiteSpace) <* eof) "lisp"

--------------------------------------------------------------------------------
-- Parsers for each type of LispVal.

lispVal :: Parser LispVal
lispVal =   parseString
        <|> parseAtom
        <|> parseNumber
        <|> parseBool
        <|> parseQuoted
        <|> parseListOrDotted

-- | Parse a Lisp string: "..."
parseString :: Parser LispVal
parseString = do
  char '"'                             -- Opening quote
  contents <- many (noneOf "\"")       -- Contents of the string
  char '"'                             -- Closing quote
  return $ String contents

-- | Parse a Lisp atom: variable names, symbols.
parseAtom :: Parser LispVal
parseAtom = do
  first <- letter <|> symbolChar       -- First character must be a letter or symbol
  rest  <- many (letter <|> digit <|> symbolChar) -- Subsequent characters
  return $ Atom (first : rest)

-- | Parse a Lisp number: one or more digits.
parseNumber :: Parser LispVal
parseNumber = do
  num <- many1 digit
  return $ Number (read num)

-- | Parse a Lisp boolean: #t or #f.
parseBool :: Parser LispVal
parseBool = do
  char '#'
  b <- oneOf "tf"
  return $ Bool (b == 't')

-- | Parse a quoted expression: 'expr => (quote expr).
parseQuoted :: Parser LispVal
parseQuoted = do
  char '\''
  x <- lispVal
  return $ List [Atom "quote", x]

-- | Parse a Lisp list or dotted list: (a b c) or (a b . c).
parseListOrDotted :: Parser LispVal
parseListOrDotted = do
  char '('
  headVals <- sepEndBy lispVal spaces    -- Parse zero or more Lisp expressions separated by spaces
  dotted   <- optionMaybe (char '.' >> spaces >> lispVal) -- Optionally parse a dotted part
  char ')'
  return $ case dotted of
    Nothing  -> List headVals
    Just val -> DottedList headVals val

-- | Characters valid in Lisp symbols.
symbolChar :: Parser Char
symbolChar = oneOf "!$%&|*+-/:<=>?@^_~#."
  
--------------------------------------------------------------------------------
-- Comment and Whitespace Handling

-- | Parse a Lisp comment starting with ';' and extending to the end of the line.
parseComment :: Parser Char
parseComment = do
    char ';'              -- Match the ';' character
    skipMany (noneOf "\n") -- Skip all characters until a newline
    option ' ' (char '\n')  -- Return newline or space if no newline

-- | Define a parser that skips spaces and comments.
whiteSpace :: Parser ()
whiteSpace = skipMany (space <|> parseComment)
