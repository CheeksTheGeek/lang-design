module Types
  ( Env
  , LispVal(..)
  ) where

import Data.Map (Map)
import Data.IORef

-- | The mutable environment is an IORef to a Map of String -> LispVal.
type Env = IORef (Map String LispVal)

-- | Represents a Lisp value.
data LispVal
  = Atom String               -- ^ Symbol.
  | Number Integer            -- ^ Integer numbers.
  | Bool Bool                 -- ^ Booleans.
  | String String             -- ^ Strings.
  | List [LispVal]            -- ^ List of values.
  | DottedList [LispVal] LispVal
  -- Store the mutable Env in the closure.
  | Lambda 
      { params  :: [String]
      , vararg  :: Maybe String
      , body    :: [LispVal]
      , closure :: Env
      }
  | PrimitiveFunc ([LispVal] -> Either String LispVal)

-- | For printing LispVal nicely.
showVal :: LispVal -> String
showVal (Atom s)         = s
showVal (Number n)       = show n
showVal (Bool True)      = "#t"
showVal (Bool False)     = "#f"
showVal (String s)       = "\"" ++ s ++ "\""
showVal (List contents)  = "(" ++ unwords (map showVal contents) ++ ")"
showVal (DottedList h t) = "(" ++ unwords (map showVal h) ++ " . " ++ showVal t ++ ")"
showVal Lambda{}         = "<lambda>"
showVal (PrimitiveFunc _) = "<primitive-func>"

instance Show LispVal where
  show = showVal
