{-# LANGUAGE AllowAmbiguousTypes #-}

{- |
Module      : HW5.Parser
Description : Parser for the Hi language
Maintainer  : vadim09531@yandex.ru

The `HW5.Parser` module provides the parser for the Hi language using the Megaparsec library.
It supports parsing expressions, values, functions, operators and actions.
The resulting expressions are represented as an abstract syntax tree (`HiExpr`).
-}
module HW5.Parser
  ( parse
  ) where

import Data.Void (Void)
import Text.Megaparsec (Parsec, between, runParser, eof, sepBy, choice, (<|>), try, notFollowedBy, ParseErrorBundle, manyTill,many, count, some)
import Text.Megaparsec.Char (char, space1, string, hexDigitChar, alphaNumChar)
import Text.Megaparsec.Char.Lexer (scientific, charLiteral)
import Control.Applicative (optional)
import Control.Monad.Combinators.Expr (Operator(..), makeExprParser)
import HW5.Base (HiExpr(..), HiFun(..), HiValue(..), HiAction(..), showFun)
import Data.Functor (($>))
import qualified Data.Text as Text
import qualified Data.ByteString as BS
import Numeric (readHex)

{- | 
The core parser type for Hi expressions.
-}
type Parser = Parsec Void String

{- |
Helper function to consume trailing whitespace after parsing a token.
-}
lexeme :: Parser a -> Parser a
lexeme p = p <* skipSpace

{- |
Parses optional whitespace (if present).
-}
skipSpace :: Parser ()
skipSpace = space1 <|> pure ()

{- |
Parses the "!" postfix operator, which runs an action.
Transforms an expression into a `HiExprRun`.
-}
runOp :: Parser (HiExpr -> HiExpr)
runOp = lexeme (char '!') *> pure HiExprRun

{- |
Parses a dictionary literal, represented as key-value pairs inside `{}`.
Example: `{ "key": "value", "x": 42 }`
-}
pDict :: Parser HiExpr
pDict = do
  entries <- between (lexeme (char '{')) (lexeme (char '}')) (pDictEntry `sepBy` lexeme (char ','))
  return $ HiExprDict entries

{- |
Parses a single dictionary entry in the form `key: value`.
-}
pDictEntry :: Parser (HiExpr, HiExpr)
pDictEntry = do
  key <- pExpr
  _ <- lexeme (char ':')
  value <- pExpr
  return (key, value)

{- |
Parses a byte array literal, represented as hexadecimal numbers between `[#` and `#]`.
Example: `[# ab cd ef #]`
-}
pBytes :: Parser HiExpr
pBytes = do
  _ <- lexeme (string "[#")
  bytes <- many (lexeme (try pHexByte))
  _ <- lexeme (string "#]")
  return $ HiExprValue (HiValueBytes (BS.concat bytes))

{- |
Parses a single two-digit hexadecimal byte.
Example: `ab`
-}
pHexByte :: Parser BS.ByteString
pHexByte = do
  hex <- count 2 hexDigitChar
  case readHex hex :: [(Integer, String)] of
    [(value, "")] -> return $ BS.singleton $ fromIntegral value
    _  -> return BS.empty

{- |
Parses a list literal, represented as elements between square brackets `[ ]`.
Example: `[1, true, "hello"]`
-}
pList :: Parser HiExpr
pList = do
  elements <- between (lexeme (char '[')) (lexeme (char ']')) (pExpr `sepBy` lexeme (char ','))
  return $ HiExprApply (HiExprValue (HiValueFunction HiFunList)) elements

{- |
Parses a string literal between double quotes.
Example: `"hello world"`
-}
pString :: Parser HiExpr
pString = lexeme $ do
  str <- char '\"' *> manyTill charLiteral (char '\"')
  return $ HiExprValue $ HiValueString $ Text.pack str

{- |
Parses the `null` literal, representing `HiValueNull`.
-}
pNull :: Parser HiExpr
pNull = lexeme $ string "null" $> HiExprValue HiValueNull

{- |
Parses the boolean literals `true` and `false`.
-}
pBool :: Parser HiExpr
pBool = lexeme $ HiExprValue <$> choice
  [ string "true"  $> HiValueBool True
  , string "false" $> HiValueBool False
  ]

{- |
Parses a number (integer or rational) with optional negative sign.
Example: `42`, `-3.14`, `1.2e5`
-}
pNumber :: Parser HiExpr
pNumber = lexeme $ do
  sign   <- optional (char '-')
  number <- scientific
  let value = case sign of
                Just _  -> - (toRational number)
                Nothing -> toRational number
  return $ HiExprValue (HiValueNumber value)

{- |
Parses a built-in function by its name.
Example: `add`, `length`, `mul`, `div`
-}
pFunction :: Parser HiExpr
pFunction = lexeme $ HiExprValue . HiValueFunction <$> choice (map parseFun (enumFrom minBound :: [HiFun]))
  where
    parseFun :: HiFun -> Parser HiFun
    parseFun fun = string (showFun fun) $> fun

{- |
Parses a built-in action.
Example: `cwd`, `now`
-}
pAction :: Parser HiExpr
pAction = lexeme $ HiExprValue . HiValueAction <$> choice
  [ string "cwd" $> HiActionCwd
  , string "now" $> HiActionNow
  ]

{- |
Parses a dot access.
Example: `{ "key": "value" }.key`
-}
pDotAccess :: Parser (HiExpr -> HiExpr)
pDotAccess = do
  _ <- lexeme (char '.')
  field <- lexeme (some alphaNumChar)
  return (\base -> HiExprApply base [HiExprValue (HiValueString (Text.pack field))])

{- |
Parses a function application or dot access.
Example: `add(1, 2)`
-}
pApply :: Parser HiExpr
pApply = do
  base <- term
  foldl (flip ($)) base <$> many (choice [pDotAccess, pFunctionCall])

{- |
Parses a function call expression of the form `base(args...)` and returns 
a higher-order function that applies the arguments to the parsed base expression.
-}
pFunctionCall :: Parser (HiExpr -> HiExpr)
pFunctionCall = do
  args <- between (lexeme (char '(')) (lexeme (char ')')) (pExpr `sepBy` lexeme (char ','))
  return (\base -> HiExprApply base args)

{- |
Parses parentheses around an expression.
Example: `(1 + 2)`
-}
pParensExpr :: Parser HiExpr
pParensExpr = between (lexeme (char '(')) (lexeme (char ')')) pExpr


{- |
Parses operators like `+`, `/`, and `&&` with their corresponding HiFun.
-}
binaryOp :: String -> HiFun -> Parser (HiExpr -> HiExpr -> HiExpr)
binaryOp symbol fun = lexeme $ try $ do
  _ <- string symbol
  case symbol of
    "/" -> do
      notFollowedBy (char '=')
    _ -> pure ()
  return $ \x y -> HiExprApply (HiExprValue (HiValueFunction fun)) [x, y]

{- |
The operator table defines precedence and associativity rules
for parsing infix operators, such as arithmetic and logical operators.
-}
operatorTable :: [[Operator Parser HiExpr]]
operatorTable =
  [ [
      Postfix runOp
    ]
  , [
      InfixL (binaryOp "*" HiFunMul),
      InfixL (binaryOp "/" HiFunDiv)
    ]
  , [
      InfixL (binaryOp "+" HiFunAdd),
      InfixL (binaryOp "-" HiFunSub)
    ]
  , [

      InfixN (binaryOp "<=" HiFunNotGreaterThan),
      InfixN (binaryOp ">=" HiFunNotLessThan),
      InfixN (binaryOp "==" HiFunEquals),
      InfixN (binaryOp "/=" HiFunNotEquals),
      InfixN (binaryOp "<" HiFunLessThan),
      InfixN (binaryOp ">" HiFunGreaterThan)
    ]
  , [InfixR (binaryOp "&&" HiFunAnd)]
  , [InfixR (binaryOp "||" HiFunOr)]
  ]

{- |
Parses a term.
This includes numbers, strings, lists, dictionaries and parenthesized expressions.
-}
term :: Parser HiExpr
term = 
  pBytes
  <|> pFunction
  <|> pAction
  <|> pNumber
  <|> pBool
  <|> pNull
  <|> pString
  <|> pList
  <|> pDict
  <|> pParensExpr


{- |
Parses the top-level expression with all operator precedence rules and term parsers.
-}
pExpr :: Parser HiExpr
pExpr = makeExprParser pApply operatorTable


{- |
Parses a Hi program string into an abstract syntax tree (`HiExpr`).
-}
parse :: String -> Either (ParseErrorBundle String Void) HiExpr
parse = runParser (skipSpace *> pExpr <* eof) ""