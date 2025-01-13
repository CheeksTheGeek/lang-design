{-# LANGUAGE FlexibleContexts #-}

module Environment
  ( Env
  , nullEnv
  , initEnv
  , lookupVar
  , defineVar
  , setVar
  ) where

import Types (Env, LispVal(..))
import qualified Data.Map as Map
import Data.IORef
import Control.Monad.Except

-- | Create a new empty environment.
nullEnv :: IO Env
nullEnv = newIORef Map.empty

-- | Initialize the environment with built-in primitives.
initEnv :: IO Env
initEnv = do
  env <- nullEnv
  addPrimitives env primitives
  return env

-- | Adds a list of primitives to the environment.
addPrimitives :: Env -> [(String, [LispVal] -> Either String LispVal)] -> IO ()
addPrimitives env prims = do
  let prims' = map (\(name, func) -> (name, PrimitiveFunc func)) prims
  modifyIORef env (Map.union (Map.fromList prims'))

-- | List of built-in primitives.
primitives :: [(String, [LispVal] -> Either String LispVal)]
primitives =
  [ ("+", numericBinop (+))
  , ("-", numericBinop (-))
  , ("*", numericBinop (*))
  , ("/", numericBinop div)
  , ("=", numBoolBinop (==))
  , ("<", numBoolBinop (<))
  , (">", numBoolBinop (>))
  , ("<=", numBoolBinop (<=))
  , (">=", numBoolBinop (>=))
  , ("&&", boolBoolBinop (&&))
  , ("||", boolBoolBinop (||))
  , ("string=?", strBoolBinop (==))
  , ("string<?", strBoolBinop (<))
  , ("string>?", strBoolBinop (>))
  -- ... add more primitives here
  ]

-- | Lookup a variable in the environment.
lookupVar :: Env -> String -> IO (Either String LispVal)
lookupVar env var = do
  envMap <- readIORef env
  case Map.lookup var envMap of
    Nothing  -> return (Left ("Unbound variable: " ++ var))
    Just val -> return (Right val)

-- | Define a new variable in the environment.
defineVar :: Env -> String -> LispVal -> IO ()
defineVar env var val = modifyIORef env (Map.insert var val)

-- | Set a variable if it exists, else error.
setVar :: Env -> String -> LispVal -> IO (Either String ())
setVar env var val = do
  envMap <- readIORef env
  if Map.member var envMap
    then do
      modifyIORef env (Map.insert var val)
      return (Right ())
    else return (Left ("Cannot set unbound variable: " ++ var))

----------------------------------------------------------------
-- Helper numeric and boolean operations for primitives

numericBinop :: (Integer -> Integer -> Integer)
             -> [LispVal]
             -> Either String LispVal
numericBinop _ []      = Left "Expected at least 1 argument"
numericBinop op params = Number . foldl1 op <$> mapM unpackNum params

unpackNum :: LispVal -> Either String Integer
unpackNum (Number n) = Right n
unpackNum bad        = Left ("Expected number, got: " ++ show bad)

numBoolBinop :: (Integer -> Integer -> Bool)
             -> [LispVal]
             -> Either String LispVal
numBoolBinop _ []       = Left "Expected 2 arguments"
numBoolBinop _ [_]      = Left "Expected 2 arguments"
numBoolBinop op [x, y]  = do
  nx <- unpackNum x
  ny <- unpackNum y
  return (Bool (nx `op` ny))
numBoolBinop _ _        = Left "Expected exactly 2 arguments"

boolBoolBinop :: (Bool -> Bool -> Bool)
              -> [LispVal]
              -> Either String LispVal
boolBoolBinop _ []                    = Left "Expected 2 arguments"
boolBoolBinop _ [_]                   = Left "Expected 2 arguments"
boolBoolBinop op [Bool x, Bool y]     = Right (Bool (x `op` y))
boolBoolBinop _ _                      = Left "Expected two booleans"

strBoolBinop :: (String -> String -> Bool)
             -> [LispVal]
             -> Either String LispVal
strBoolBinop _ []                        = Left "Expected 2 arguments"
strBoolBinop _ [_]                       = Left "Expected 2 arguments"
strBoolBinop op [String x, String y]     = Right (Bool (x `op` y))
strBoolBinop _ _                         = Left "Expected two strings"
