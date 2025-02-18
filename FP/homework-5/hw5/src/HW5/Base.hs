{-# LANGUAGE DeriveAnyClass       #-}
{-# LANGUAGE DeriveGeneric        #-}
{-# LANGUAGE DerivingStrategies   #-}


{- |
Module      : HW5.Base
Description : Core data types and utilities for the Hi interpreter
Maintainer  : vadim09531@yandex.ru

This module defines the core data types, including expressions, values, actions, 
functions and errors for the Hi language. It also includes utility 
functions for determining function arities, laziness and argument handling.
-}
module HW5.Base
  ( HiError(..)       -- ^ Errors that can occur during evaluation
  , HiExpr(..)        -- ^ Syntax tree expressions in Hi language
  , HiFun(..)         -- ^ Built-in functions of the language
  , HiValue(..)       -- ^ Types of values processed by the language
  , HiAction(..)      -- ^ Supported external actions
  , HiMonad(..)       -- ^ A type class for monads that can execute HiActions
  , arity             -- ^ Get the number of required arguments for a function
  , isLazy            -- ^ Check if a function supports lazy evaluation
  , applyNullArgs     -- ^ Check if null (`HiValueNull`) arguments are valid for a function
  , showFun           -- ^ Convert a function name to its string representation
  ) where

import Data.Text (Text)
import Data.Sequence (Seq)
import Data.ByteString (ByteString)
import Codec.Serialise (Serialise)
import GHC.Generics (Generic)
import Data.Time (UTCTime)
import Data.Map (Map)

{- |
Represents external actions that can be executed using `HiMonad`.

Supported actions:
* File and directory operations (reading, writing, creating directories, etc.)
* Random number generation
* Working with the current system time
* Echoing text to the console
-}
data HiAction =
    HiActionCwd                       -- ^ Retrieve the current working directory
  | HiActionNow                       -- ^ Retrieve the current date and time
  | HiActionRand Int Int              -- ^ Generate a random integer within a range
  | HiActionWrite FilePath ByteString -- ^ Write binary data to a file
  | HiActionMkDir FilePath            -- ^ Create a new directory
  | HiActionChDir FilePath            -- ^ Change the current working directory
  | HiActionRead  FilePath            -- ^ Read the contents of a file or directory
  | HiActionEcho Text                 -- ^ Print text to the standard output
  deriving (Show, Eq, Generic, Ord)
  deriving anyclass Serialise



{- |
Defines all built-in functions supported by the language. Each function has
a specific arity and behavior. Functions are classified into the following categories:

- Arithmetic operations: `HiFunAdd`, `HiFunSub`, etc.
- Logical operators: `HiFunAnd`, `HiFunOr`, etc.
- String and list operations: `HiFunLength`, `HiFunReverse`, etc.
- Byte and dictionary manipulation: `HiFunPackBytes`, `HiFunCount`, etc.
- Control flow: `HiFunIf`.
- File and external operations: `HiFunRead`, `HiFunWrite`, etc.
-}
data HiFun
  = HiFunDiv               -- ^ Division
  | HiFunMul               -- ^ Multiplication
  | HiFunAdd               -- ^ Addition
  | HiFunSub               -- ^ Subtraction
  | HiFunAnd               -- ^ Logical AND
  | HiFunOr                -- ^ Logical OR
  | HiFunLessThan          -- ^ Less-than comparison
  | HiFunGreaterThan       -- ^ Greater-than comparison
  | HiFunEquals            -- ^ Equality comparison
  | HiFunNotLessThan       -- ^ Not-less-than comparison
  | HiFunNotGreaterThan    -- ^ Not-greater-than comparison
  | HiFunNotEquals         -- ^ Inequality comparison
  | HiFunNot               -- ^ Logical NOT
  | HiFunIf                -- ^ Conditional branching
  | HiFunLength            -- ^ Get the length of a string, list, or bytes
  | HiFunToUpper           -- ^ Convert a string to uppercase
  | HiFunToLower           -- ^ Convert a string to lowercase
  | HiFunReverse           -- ^ Reverse a string or list
  | HiFunTrim              -- ^ Trim whitespace from a string
  | HiFunList              -- ^ Create a list
  | HiFunRange             -- ^ Generate a range of numbers
  | HiFunFold              -- ^ Apply a function repeatedly to a list
  | HiFunPackBytes         -- ^ Pack bytes into binary format
  | HiFunUnpackBytes       -- ^ Unpack binary data into a list of bytes
  | HiFunEncodeUtf8        -- ^ Encode a string into UTF-8
  | HiFunDecodeUtf8        -- ^ Decode UTF-8 into a string
  | HiFunZip               -- ^ Compress data using ZIP
  | HiFunUnzip             -- ^ Decompress ZIP-compressed data
  | HiFunSerialise         -- ^ Serialize a value into binary
  | HiFunDeserialise       -- ^ Deserialize binary data into a value
  | HiFunRead              -- ^ Read data from a file or directory
  | HiFunWrite             -- ^ Write data to a file
  | HiFunMkDir             -- ^ Create a new directory
  | HiFunChDir             -- ^ Change the current directory
  | HiFunParseTime         -- ^ Parse a string into a time value
  | HiFunRand              -- ^ Generate a random number
  | HiFunEcho              -- ^ Print a string to the standard output
  | HiFunCount             -- ^ Count occurrences in a list or string
  | HiFunKeys              -- ^ Get the keys from a dictionary
  | HiFunValues            -- ^ Get the values from a dictionary
  | HiFunInvert            -- ^ Invert keys and values in a dictionary
  deriving (Eq, Enum, Bounded, Generic, Ord, Show)
  deriving anyclass Serialise


{- |
Represents the types of values that can exist in the Hi language.

Examples include:
* Numbers (`HiValueNumber`)
* Strings (`HiValueString`)
* Lists (`HiValueList`)
* Functions (`HiValueFunction`)
* Actions (`HiValueAction`)
* Dictionaries (`HiValueDict`)
-}
data HiValue
  = HiValueNumber Rational            -- ^ A number (rational)
  | HiValueFunction HiFun             -- ^ A reference to a built-in function
  | HiValueBool Bool                  -- ^ A boolean value
  | HiValueNull                       -- ^ A null value
  | HiValueString Text                -- ^ A string
  | HiValueList (Seq HiValue)         -- ^ A list of values
  | HiValueBytes ByteString           -- ^ Binary data
  | HiValueAction HiAction            -- ^ An external action
  | HiValueTime UTCTime               -- ^ A time value
  | HiValueDict (Map HiValue HiValue) -- ^ A dictionary
  deriving (Show, Eq, Generic)
  deriving anyclass Serialise

{- |
Represents expressions in the Hi language, forming the syntax tree.

Expressions include:
* Values (`HiExprValue`)
* Function apply (`HiExprApply`)
* Executing actions (`HiExprRun`)
* Dictionary literals (`HiExprDict`)
-}
data HiExpr
  = HiExprValue HiValue             -- ^ A literal value
  | HiExprApply HiExpr [HiExpr]     -- ^ Application of a function
  | HiExprRun HiExpr                -- ^ Execution of an action
  | HiExprDict [(HiExpr, HiExpr)]   -- ^ A dictionary literal
  deriving (Show, Eq, Ord)

{- |
Represents errors that can occur during Hi evaluation.

Possible errors include:
* `HiErrorInvalidArgument` — An invalid argument was passed to a function.
* `HiErrorInvalidFunction` — An attempt was made to call something that is not a function.
* `HiErrorArityMismatch` — Incorrect number of arguments supplied to a function.
* `HiErrorDivideByZero` — Division by zero occurred.
-}
data HiError
  = HiErrorInvalidArgument       -- ^ Invalid argument passed to a function
  | HiErrorInvalidFunction       -- ^ Attempted call to a non-function
  | HiErrorArityMismatch         -- ^ Incorrect number of arguments for a function
  | HiErrorDivideByZero          -- ^ Division by zero
  deriving (Show, Eq)

{- |
A type class for monads that can execute `HiAction` actions.
-}
class Monad m => HiMonad m where
  runAction :: HiAction -> m HiValue

{- |
Converts a `HiFun` to its string representation.
-}
showFun :: HiFun -> String
showFun fun = case fun of
    HiFunDiv -> "div"
    HiFunMul -> "mul"
    HiFunAdd -> "add"
    HiFunSub -> "sub"
    HiFunNot -> "not"
    HiFunAnd -> "and"
    HiFunOr -> "or"
    HiFunLessThan -> "less-than"
    HiFunGreaterThan -> "greater-than"
    HiFunEquals -> "equals"
    HiFunNotLessThan -> "not-less-than"
    HiFunNotGreaterThan -> "not-greater-than"
    HiFunNotEquals -> "not-equals"
    HiFunIf -> "if"
    HiFunLength -> "length"
    HiFunToUpper -> "to-upper"
    HiFunToLower -> "to-lower"
    HiFunReverse -> "reverse"
    HiFunTrim -> "trim"
    HiFunList -> "list"
    HiFunRange -> "range"
    HiFunFold -> "fold"
    HiFunPackBytes -> "pack-bytes"
    HiFunUnpackBytes -> "unpack-bytes"
    HiFunEncodeUtf8 -> "encode-utf8"
    HiFunDecodeUtf8 -> "decode-utf8"
    HiFunZip -> "zip"
    HiFunUnzip -> "unzip"
    HiFunSerialise -> "serialise"
    HiFunDeserialise -> "deserialise"
    HiFunRead -> "read"
    HiFunWrite -> "write"
    HiFunMkDir -> "mkdir"
    HiFunChDir -> "cd"
    HiFunParseTime -> "parse-time"
    HiFunRand -> "rand"
    HiFunEcho -> "echo"
    HiFunCount -> "count"
    HiFunKeys -> "keys"
    HiFunValues -> "values"
    HiFunInvert -> "invert"


{- |
Determines the arity (number of arguments) of a given `HiFun`.

Each built-in function in Hi has a predefined arity:
- Unary functions (e.g., `HiFunNot`, `HiFunLength`) return 1.
- Binary functions (e.g., `HiFunAdd`, `HiFunDiv`) return 2.
- Ternary functions (e.g., `HiFunIf`) return 3.
- Special functions like `HiFunList` return -1 to indicate a variable number of arguments.
-}
arity :: HiFun -> Int
arity fun = case fun of
    HiFunDiv -> 2
    HiFunMul -> 2
    HiFunAdd -> 2
    HiFunSub -> 2
    HiFunNot -> 1
    HiFunAnd -> 2
    HiFunOr -> 2
    HiFunLessThan -> 2
    HiFunGreaterThan -> 2
    HiFunEquals -> 2
    HiFunNotLessThan -> 2
    HiFunNotGreaterThan -> 2
    HiFunNotEquals -> 2
    HiFunIf -> 3
    HiFunLength -> 1
    HiFunToUpper -> 1
    HiFunToLower -> 1
    HiFunReverse -> 1
    HiFunTrim -> 1
    HiFunList -> -1
    HiFunRange -> 2
    HiFunFold -> 2
    HiFunPackBytes -> 1
    HiFunUnpackBytes -> 1
    HiFunEncodeUtf8 -> 1
    HiFunDecodeUtf8 -> 1
    HiFunZip -> 1
    HiFunUnzip -> 1
    HiFunSerialise -> 1
    HiFunDeserialise -> 1
    HiFunRead -> 1
    HiFunWrite -> 2
    HiFunMkDir -> 1
    HiFunChDir -> 1
    HiFunParseTime -> 1
    HiFunRand -> 2
    HiFunEcho -> 1
    HiFunCount -> 1
    HiFunKeys -> 1
    HiFunValues -> 1
    HiFunInvert -> 1


{- |
Checks whether a given function supports lazy evaluation.
-}
isLazy :: HiFun -> Bool
isLazy fun = case fun of
  HiFunIf -> True
  HiFunAnd -> True
  HiFunOr -> True
  _ -> False

{- |
Determines whether a given function can accept null (`HiValueNull`) as valid arguments.
-}
applyNullArgs :: HiFun -> Bool
applyNullArgs fun = case fun of
  HiFunEquals -> True
  HiFunNotEquals -> True
  HiFunLessThan -> True  
  HiFunGreaterThan -> True
  HiFunNotGreaterThan -> True
  HiFunNotLessThan -> True
  HiFunList -> True
  _ -> False

{- |
Defines an ordering for `HiValue`.
-}
instance Ord HiValue where
  compare HiValueNull HiValueNull = EQ
  compare HiValueNull _ = LT
  compare _ HiValueNull = GT

  compare (HiValueBool x) (HiValueBool y) = compare x y
  compare (HiValueBool _) _ = LT
  compare _ (HiValueBool _) = GT

  compare (HiValueNumber x) (HiValueNumber y) = compare x y
  compare (HiValueNumber _) _ = LT
  compare _ (HiValueNumber _) = GT

  compare (HiValueString x) (HiValueString y) = compare x y
  compare (HiValueString _) _ = LT
  compare _ (HiValueString _) = GT

  compare (HiValueList x) (HiValueList y) = compare x y
  compare (HiValueList _) _ = LT
  compare _ (HiValueList _) = GT

  compare (HiValueBytes x) (HiValueBytes y) = compare x y
  compare (HiValueBytes _) _ = LT
  compare _ (HiValueBytes _) = GT

  compare (HiValueTime x) (HiValueTime y) = compare x y
  compare (HiValueTime _) _ = LT
  compare _ (HiValueTime _) = GT

  compare (HiValueDict x) (HiValueDict y) = compare x y
  compare (HiValueDict _) _ = LT
  compare _ (HiValueDict _) = GT

  compare (HiValueFunction x) (HiValueFunction y) = compare x y
  compare (HiValueFunction _) _ = LT
  compare _ (HiValueFunction _) = GT

  compare (HiValueAction x) (HiValueAction y) = compare x y
  -- compare (HiValueAction _) _ = LT
  -- compare _ (HiValueAction _) = GT

