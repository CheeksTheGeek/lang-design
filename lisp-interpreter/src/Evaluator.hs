{-# LANGUAGE NamedFieldPuns #-}

module Evaluator
  ( eval
  ) where

import Types (Env, LispVal(..))
import Environment (lookupVar, defineVar, setVar)
import Control.Monad (foldM)
import Data.Maybe (isNothing)
import Control.Exception (try, IOException)
import Parser (parseExpr, parseExprs)
import System.IO (readFile)

-- | Evaluate a LispVal expression in the provided environment.
eval :: Env -> LispVal -> IO (Either String LispVal)
eval env val@(String _) = return $ Right val
eval env val@(Number _) = return $ Right val
eval env val@(Bool _)   = return $ Right val

-- Variable lookup.
eval env (Atom var) =
  lookupVar env var

-- Quote special form: (quote expr).
eval env (List [Atom "quote", val]) = return $ Right val

-- If special form: (if pred conseq alt).
eval env (List [Atom "if", pred, conseq, alt]) = do
  result <- eval env pred
  case result of
    Left err -> return $ Left err
    Right (Bool True)  -> eval env conseq
    Right (Bool False) -> eval env alt
    Right _            -> return $ Left "if predicate must evaluate to a boolean"

-- Define variable: (define var expr).
eval env (List [Atom "define", Atom var, form]) = do
  value <- eval env form
  case value of
    Left err -> return $ Left err
    Right val -> do
      defineVar env var val
      return $ Right val

-- Load function: (load "filename.lisp").
eval env (List [Atom "load", String filename]) = loadFile env filename

-- Lambda definitions: (lambda (params) body).
eval env (List (Atom "lambda" : List paramList : body)) =
  case extractParams paramList of
    Left err      -> return $ Left err
    Right params' -> do
      -- Capture the current environment's snapshot.
      return $ Right $ Lambda params' Nothing body env

-- Function application: (fn arg1 arg2 ...).
eval env (List (fn : args)) = do
  funcResult <- eval env fn
  case funcResult of
    Left err -> return $ Left err
    Right func -> do
      argVals <- mapM (eval env) args
      if any isLeft argVals
        then return $ Left "Error in arguments"
        else do
          let args' = rights argVals
          apply func args'

-- Fall-through: unrecognized form.
eval _ badForm = return $ Left $ "Unrecognized expression: " ++ show badForm

--------------------------------------------------------------
-- Function application.

apply :: LispVal -> [LispVal] -> IO (Either String LispVal)
apply (PrimitiveFunc func) args = return $ func args
apply Lambda{ params, vararg, body, closure } args =
  if length params /= length args && isNothing vararg
    then return $ Left $ "Expected " ++ show (length params) ++ " args, got " ++ show (length args)
    else do
      let bindVar e (p, a) = defineVar e p a >> return e
      -- Bind parameters to arguments in the closure environment.
      newEnv <- foldM bindVar closure (zip params args)
      applyBody newEnv body
apply notFunc _ = return $ Left $ "Attempt to call non-function: " ++ show notFunc


-- | Evaluate each expression in turn, returning the last one.
applyBody :: Env -> [LispVal] -> IO (Either String LispVal)
applyBody _   []     = return $ Right $ List []
applyBody env [x]    = eval env x
applyBody env (x:xs) = do
  _ <- eval env x
  applyBody env xs

-- | Extract parameter names from a list of LispVal.
extractParams :: [LispVal] -> Either String [String]
extractParams = mapM extractParam
  where
    extractParam (Atom s) = Right s
    extractParam notAtom  = Left $ "Expected atom in parameter list, got: " ++ show notAtom

-- | Load and evaluate expressions from a file.
loadFile :: Env -> String -> IO (Either String LispVal)
loadFile env filename = do
  result <- try (readFile filename) :: IO (Either IOException String)
  case result of
    Left ex -> return $ Left $ "Error reading file " ++ filename ++ ": " ++ show ex
    Right content ->
      case parseExprs content of
        Left parseErr -> return $ Left $ "Parse error in file " ++ filename ++ ": " ++ show parseErr
        Right exprs    -> evalMany env exprs

-- | Evaluate a list of expressions sequentially.
evalMany :: Env -> [LispVal] -> IO (Either String LispVal)
evalMany _   []     = return $ Right $ List []
evalMany env (x:xs) = do
  result <- eval env x
  case result of
    Left err -> return $ Left err
    Right _  -> evalMany env xs

-- Helper functions.
isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft _        = False

rights :: [Either a b] -> [b]
rights = foldr (\x acc -> case x of Right val -> val : acc; Left _ -> acc) []
