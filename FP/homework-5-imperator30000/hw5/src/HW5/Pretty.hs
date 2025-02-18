{- |
Module      : HW5.Pretty
Description : Pretty printer for Hi values
Maintainer  : vadim09531@yandex.ru

Provides functionality to format Hi values (`HiValue`)
in a human-readable form.
-}
module HW5.Pretty
  ( prettyValue
  ) where

import Prettyprinter (Doc, pretty, (<+>), dquotes, brackets, encloseSep)
import Prettyprinter.Render.Terminal (AnsiStyle)
import Data.Ratio (numerator, denominator)
import Data.Foldable (toList)
import HW5.Base (HiValue(..), HiAction(..), showFun)
import Numeric (showHex)
import qualified Data.ByteString as BS
import qualified Data.Map.Strict as Map

{- |
Checks if a rational number is representable as a finite decimal fraction.
-}
isFiniteDecimal :: Rational -> Bool
isFiniteDecimal r = reduce denom == 1
  where
    denom = denominator r
    reduce x
      | x `mod` 2 == 0 = reduce (x `div` 2)
      | x `mod` 5 == 0 = reduce (x `div` 5)
      | otherwise      = x 

{- |
Formats a `Rational` value as an integer, finite decimal, fraction or mixed fraction.
-}
prettyRational :: Rational -> Doc AnsiStyle
prettyRational r
  | denominator r == 1 = pretty (numerator r)
  | isFiniteDecimal r  = pretty (fromRational r :: Double)
  | whole /= 0         = pretty whole <+> pretty (if fracNum < 0 then "-" else "+") <+> pretty (abs fracNum) <+> pretty "/" <+> pretty denom
  | otherwise          = pretty fracNum <+> pretty "/" <+> pretty denom
  where
    whole   = numerator r `quot` denominator r
    fracNum = numerator r `rem` denominator r
    denom   = denominator r

{- |
Pretty-prints a `HiValue` into a human-readable format.
-}
prettyValue :: HiValue -> Doc AnsiStyle
prettyValue (HiValueNumber r)      = prettyRational r
prettyValue (HiValueFunction f)    = pretty (showFun f)
prettyValue (HiValueBool b)        = pretty $ if b then "true" else "false"
prettyValue (HiValueString s)      = dquotes (pretty s)
prettyValue HiValueNull            = pretty "null"
prettyValue (HiValueList lst)      =
  let elements = toList lst
  in brackets $ encloseSep mempty mempty (pretty ", ") (map prettyValue elements)  
prettyValue (HiValueBytes bs) =
  let hexChunks = map (padHex . (`showHex` "")) (BS.unpack bs)
  in brackets $ pretty "#" <+> pretty (unwords hexChunks) <+> pretty "#"
  where
    padHex x = if length x == 1 then '0' : x else x
prettyValue (HiValueAction action) = prettyHiAction action
prettyValue (HiValueTime utcTime)  =
  dquotes $ pretty $ show utcTime
prettyValue (HiValueDict dict)     =
  let elements = Map.toList dict
      prettyKeyValue (k, v) = prettyValue k <+> pretty ":" <+> prettyValue v
  in encloseSep (pretty "{") (pretty "}") (pretty ", ") (map prettyKeyValue elements)

{- |
Pretty-prints a `HiAction` in a function-like format.
-}
prettyHiAction :: HiAction -> Doc AnsiStyle
prettyHiAction action = case action of
  HiActionRead path          -> wrapWithParens "read" [dquotes (pretty path)]
  HiActionWrite path bytes   -> wrapWithParens "write" [dquotes (pretty path), prettyValue (HiValueBytes bytes)]
  HiActionMkDir path         -> wrapWithParens "mkdir" [dquotes (pretty path)]
  HiActionChDir path         -> wrapWithParens "cd" [dquotes (pretty path)]
  HiActionCwd                -> pretty "cwd"
  HiActionNow                -> pretty "now"
  HiActionRand from to       -> wrapWithParens "rand" [pretty from, pretty to]
  HiActionEcho text          -> wrapWithParens "echo" [dquotes (pretty text)]

{- |
Wraps a name and arguments.
-}
wrapWithParens :: String -> [Doc AnsiStyle] -> Doc AnsiStyle
wrapWithParens name args = pretty name <> pretty "(" <> encloseSep mempty mempty (pretty ", ") args <> pretty ")"