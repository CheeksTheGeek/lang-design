module REPL
  ( runRepl
  ) where

import System.IO (hFlush, stdout)
import Control.Monad (void)
import Types (Env)
import Parser (parseExpr, parseExprs)
import Evaluator (eval)
import Environment (initEnv, Env)
import Text.Parsec (ParseError)

-- | Runs an interactive REPL.
runRepl :: IO ()
runRepl = do
  putStrLn "Welcome to the Haskell Lisp Interpreter!"
  env <- initEnv
  loop env

-- | The REPL loop with a mutable environment.
loop :: Env -> IO ()
loop env = do
  putStr "Lisp>>> "
  hFlush stdout
  input <- getLine
  case input of
    ""       -> loop env        -- Empty input, just continue.
    ":quit"  -> putStrLn "Goodbye!"
    _        -> do
      case parseExpr input of
        Left parseErr -> do
          putStrLn ("Parse error: " ++ show parseErr)
          loop env
        Right expr -> do
          evalResult <- eval env expr
          case evalResult of
            Left err -> putStrLn ("Eval error: " ++ err)
            Right val -> print val
          loop env
