{- |
Module      : HW5.Evaluator
Description : Evaluator for the Hi language
Maintainer  : vadim09531@yandex.ru

The `HW5.Evaluator` module contains the main logic for evaluating expressions (`HiExpr`) 
and functions (`HiFun`) in the Hi language. It supports arithmetic operations, 
boolean logic, string manipulation, list and byte operations as well as file system actions 
using `HiAction`.

The evaluation process handles lazy functions, arity checks, error propagation and IO actions.
-}
module HW5.Evaluator
  ( eval
  ) where

import HW5.Base (HiError(..), HiExpr(..), HiValue(..), HiFun(..), HiMonad(..), HiAction(..), arity, isLazy, applyNullArgs)
import Control.Monad.Except (throwError, runExceptT, ExceptT)
import qualified Data.Text as Text
import Data.Semigroup (stimes)
import Data.Ratio (numerator, denominator)
import qualified Data.Sequence as Seq
import Control.Monad (foldM, forM)
import qualified Data.ByteString as BS
import Data.Foldable (toList)
import Data.Word (Word8)
import qualified Data.Text.Encoding as Encoding
import qualified Data.ByteString.Lazy as BSL
import qualified Codec.Compression.Zlib as Zlib
import qualified Codec.Serialise as Serialise
import Control.Monad.Trans.Class (lift)
import Data.Time (UTCTime, addUTCTime, diffUTCTime)
import Text.Read (readMaybe)
import qualified Data.Map as Map

{- |
Evaluates an expression (`HiExpr`) and returns the result in the context of the given monad.
-}
eval :: HiMonad m => HiExpr -> m (Either HiError HiValue)
eval expr = runExceptT (evalExpr expr)

{- |
Selects an element from a container by its index.
Returns `HiValueNull` if the index is out of bounds.
-}
index :: Monad m
          => (Int -> a -> HiValue)
          -> (a -> Int)
          -> a
          -> Rational
          -> ExceptT HiError m HiValue
index indexF lenF container idx = do
  i <- rationalToIntM idx
  let len = lenF container
  if i < 0 || i >= len
    then return HiValueNull
    else return $ indexF i container

{- |
Slices a container between the `from` and `to` indices.
-}
slice :: (Monad m)
      => (Int -> a -> a)
      -> (Int -> a -> a)
      -> (a -> Int)
      -> a
      -> Rational
      -> Rational
      -> ExceptT HiError m a
slice takeF dropF lenF container from to = do
  intFrom <- rationalToIntM from
  intTo <- rationalToIntM to
  let len = lenF container
      normFrom = normalizeIndex len intFrom
      normTo   = normalizeIndex len intTo
  return $ takeF (normTo - normFrom) (dropF normFrom container)

{- |
Counts occurrences of elements in a container and returns a map.
-}
countMap :: (Foldable f, Ord k)
         => (a -> k)
         -> f a 
         -> Map.Map k Rational
countMap toKey container =
  Map.map toRational $ foldr (\item acc -> Map.insertWith (+) (toKey item) (1 :: Integer) acc) Map.empty container

{- |
Normalizes indices for slicing.
-}
normalizeIndex :: Int -> Int -> Int
normalizeIndex len idx
  | idx < 0   = max 0 (len + idx)
  | otherwise = min len idx

{- |
Converts a list of `HiValue`s into a `Seq`.
-}
listToSeq :: [HiValue] -> Seq.Seq HiValue
listToSeq = Seq.fromList

{- |
Converts a `Rational` number to an integer if possible.
-}
rationalToIntM :: (Monad m) => Rational -> ExceptT HiError m Int
rationalToIntM r
  | denominator r == 1 = return (fromIntegral (numerator r))
  | otherwise = throwError HiErrorInvalidArgument 

{- |
Evaluates a function-like call on a `HiValue` with a list of arguments.
-}
evalVal :: HiMonad m => HiValue -> [HiExpr] -> ExceptT HiError m HiValue
evalVal (HiValueString s) [HiExprValue (HiValueNumber x), HiExprValue (HiValueNumber y)] =
  HiValueString <$> slice Text.take Text.drop Text.length s x y

evalVal (HiValueString s) [HiExprValue HiValueNull, HiExprValue (HiValueNumber y)] =
  HiValueString <$> slice Text.take Text.drop Text.length s 0 y

evalVal (HiValueString s) [HiExprValue (HiValueNumber x), HiExprValue HiValueNull] = 
  HiValueString <$> slice Text.take Text.drop Text.length s x (toRational (Text.length s))

evalVal (HiValueList xs) [HiExprValue HiValueNull, HiExprValue (HiValueNumber y)] =
  HiValueList <$> slice Seq.take Seq.drop Seq.length xs 0 y

evalVal (HiValueList xs) [HiExprValue (HiValueNumber x), HiExprValue HiValueNull] =
  HiValueList <$> slice Seq.take Seq.drop Seq.length xs x (toRational (Seq.length xs))

evalVal (HiValueList xs) [HiExprValue (HiValueNumber x), HiExprValue (HiValueNumber y)] =
  HiValueList <$> slice Seq.take Seq.drop Seq.length xs x y

evalVal (HiValueBytes xs) [HiExprValue HiValueNull, HiExprValue (HiValueNumber y)] =
  HiValueBytes <$> slice BS.take BS.drop BS.length xs 0 y

evalVal (HiValueBytes xs) [HiExprValue (HiValueNumber x), HiExprValue HiValueNull] =
  HiValueBytes <$> slice BS.take BS.drop BS.length xs x (toRational (BS.length xs))

evalVal (HiValueBytes xs) [HiExprValue (HiValueNumber x), HiExprValue (HiValueNumber y)] =
  HiValueBytes <$> slice BS.take BS.drop BS.length xs x y



evalVal (HiValueString s) [HiExprValue (HiValueNumber x)] =
  index (\i txt -> HiValueString (Text.singleton (Text.index txt i))) Text.length s x

evalVal (HiValueList xs) [HiExprValue (HiValueNumber x)] =
  index (\i lst -> Seq.index lst i) Seq.length xs x

evalVal (HiValueBytes xs) [HiExprValue (HiValueNumber x)] =
  index (\i bs -> HiValueNumber (toRational (BS.index bs i))) BS.length xs x

evalVal (HiValueDict dict) [keyExpr] = do
  key <- evalExpr keyExpr
  case Map.lookup key dict of
    Just value -> do
      return value
    Nothing -> do
      return HiValueNull

evalVal _ _ = throwError HiErrorInvalidFunction

{- |
Evaluates the value of an expression (`HiExpr`) and returns the result.

This function handles lazy functions, strict evaluation and arity validation.
It dispatches the execution to different routines based on the structure of the expression.
-}
evalExpr :: HiMonad m => HiExpr -> ExceptT HiError m HiValue
evalExpr (HiExprValue v) = return v
evalExpr (HiExprRun expr) = do
  evaluated <- evalExpr expr
  case evaluated of
    HiValueAction action -> lift $ runAction action
    _                    -> throwError HiErrorInvalidArgument
evalExpr (HiExprApply funExpr args) = do
  evaluated <- evalExpr funExpr
  case evaluated of
    HiValueFunction f 
      | length args /= arity f && -1 /= arity f -> throwError HiErrorArityMismatch
      | isLazy f -> evalLazyFunction f args
      | applyNullArgs f -> do
          evalArgs <- mapM evalExpr args
          evalFunction f evalArgs
      | otherwise -> evalStrictFunction f args
    _ -> evalVal evaluated args
evalExpr (HiExprDict entries) = do
  evaledEntries <- mapM (\(k, v) -> (,) <$> evalExpr k <*> evalExpr v) entries
  return $ HiValueDict (Map.fromList evaledEntries)

{- |
Evaluates strict functions by first evaluating all arguments and then applying the function.
If any argument is `null`, it throws `HiErrorInvalidArgument`.
-}
evalStrictFunction :: HiMonad m => HiFun -> [HiExpr] -> ExceptT HiError m HiValue
evalStrictFunction f args = do
  evalArgs <- forM args $ \arg -> do
    value <- evalExpr arg
    case value of
      HiValueNull -> throwError HiErrorInvalidArgument
      _           -> return value
  evalFunction f evalArgs

{- |
Evaluates lazy functions (`if`, `and`, `or`) without evaluating unnecessary branches or arguments.
-}
evalLazyFunction :: HiMonad m => HiFun -> [HiExpr] -> ExceptT HiError m HiValue
evalLazyFunction HiFunIf [condExpr, trueBranchExpr, falseBranchExpr] = do
  condition <- evalExpr condExpr
  case condition of
    HiValueBool True  -> evalExpr trueBranchExpr
    HiValueBool False -> evalExpr falseBranchExpr
    HiValueNull -> evalExpr falseBranchExpr
    _                 -> throwError HiErrorInvalidArgument 
evalLazyFunction HiFunAnd [leftExpr, rightExpr] = do
  evaluatedLeft <- evalExpr leftExpr
  case evaluatedLeft of
    HiValueBool False -> return evaluatedLeft 
    HiValueNull       -> return evaluatedLeft
    _                 -> evalExpr rightExpr

evalLazyFunction HiFunOr [leftExpr, rightExpr] = do
  evaluatedLeft <- evalExpr leftExpr
  case evaluatedLeft of
    HiValueBool True  -> return evaluatedLeft
    HiValueNull       -> evalExpr rightExpr
    HiValueBool False -> evalExpr rightExpr
    _                 -> return evaluatedLeft
evalLazyFunction fun args
  | length args /= arity fun = throwError HiErrorArityMismatch
  | otherwise = throwError HiErrorInvalidArgument


{- |
Evaluates built-in Hi functions (`HiFun`) based on their arguments.
-}
evalFunction :: HiMonad m => HiFun -> [HiValue] -> ExceptT HiError m HiValue
evalFunction HiFunAdd [HiValueNumber x, HiValueNumber y] = return $ HiValueNumber (x + y)
evalFunction HiFunAdd [HiValueString x, HiValueString y] = return $ HiValueString (x <> y)
evalFunction HiFunAdd [HiValueList xs, HiValueList ys] = return $ HiValueList (xs <> ys)
evalFunction HiFunAdd [HiValueBytes xs, HiValueBytes ys] = return $ HiValueBytes (xs <> ys)
evalFunction HiFunAdd [HiValueTime time, HiValueNumber secs] =
  return $ HiValueTime $ addUTCTime (fromRational secs) time
evalFunction HiFunAdd [HiValueNumber secs, HiValueTime time] =
  return $ HiValueTime $ addUTCTime (fromRational secs) time

evalFunction HiFunSub [HiValueNumber x, HiValueNumber y] = return $ HiValueNumber (x - y)
evalFunction HiFunSub [HiValueTime time1, HiValueTime time2] =
  return $ HiValueNumber $ toRational $ diffUTCTime time1 time2

evalFunction HiFunMul [HiValueNumber x, HiValueNumber y] = return $ HiValueNumber (x * y)
evalFunction HiFunMul [x, HiValueNumber y] = do
  times <- rationalToIntM y
  processMul x times

evalFunction HiFunDiv [HiValueNumber x, HiValueNumber y]
  | y == 0    = throwError HiErrorDivideByZero
  | otherwise = return $ HiValueNumber (x / y)
evalFunction HiFunDiv [HiValueString x, HiValueString y] =
  return $ HiValueString (x <> Text.pack "/" <> y)

evalFunction HiFunNot [HiValueBool x] = return $ HiValueBool (not x)


evalFunction HiFunEquals [x, y] = return $ HiValueBool (x == y)
evalFunction HiFunNotEquals [x, y] = return $ HiValueBool (x /= y)


evalFunction HiFunLessThan [x, y] = return $ HiValueBool (x < y)
evalFunction HiFunGreaterThan [x, y] = return $ HiValueBool (x > y)
evalFunction HiFunNotGreaterThan [x, y] = return $ HiValueBool (x <= y)
evalFunction HiFunNotLessThan [x, y] = return $ HiValueBool (x >= y)


evalFunction HiFunLength [HiValueString s] = return $ HiValueNumber (toRational (Text.length s))
evalFunction HiFunLength [HiValueList xs] = return $ HiValueNumber (toRational (Seq.length xs))

evalFunction HiFunToUpper [HiValueString s] = return $ HiValueString (Text.toUpper s)
evalFunction HiFunToLower [HiValueString s] = return $ HiValueString (Text.toLower s)

evalFunction HiFunReverse [HiValueString s] = return $ HiValueString (Text.reverse s)
evalFunction HiFunReverse [HiValueList s] = return $ HiValueList (Seq.reverse s)

evalFunction HiFunTrim [HiValueString s] = return $ HiValueString (Text.strip s)

evalFunction HiFunList args = return $ HiValueList (listToSeq args)

evalFunction HiFunRange [HiValueNumber from, HiValueNumber to] = do
  return $ HiValueList $ Seq.fromList [HiValueNumber x | x <- [from .. to]]

evalFunction HiFunKeys [HiValueDict dict] =
  return $ HiValueList $ Seq.fromList $ Map.keys dict

evalFunction HiFunValues [HiValueDict dict] =
  return $ HiValueList $ Seq.fromList $ Map.elems dict

evalFunction HiFunFold [HiValueFunction fun, HiValueList lst] = do
  if Seq.null lst
    then return HiValueNull
    else foldM (applyBinary fun) (Seq.index lst 0) (Seq.drop 1 lst)

    
evalFunction HiFunPackBytes [HiValueList values] = do
  bytes <- mapM extractByte (toList values)
  return $ HiValueBytes $ BS.pack bytes
  where
    extractByte :: HiMonad m => HiValue -> ExceptT HiError m Word8
    extractByte (HiValueNumber n)
      | denominator n == 1 && numerator n >= 0 && numerator n <= 255 =
          return $ fromIntegral $ numerator n
      | otherwise = throwError HiErrorInvalidArgument
    extractByte _ = throwError HiErrorInvalidArgument

evalFunction HiFunUnpackBytes [HiValueBytes bs] =
  return $ HiValueList $ Seq.fromList $ map (HiValueNumber . fromIntegral) $ BS.unpack bs

evalFunction HiFunEncodeUtf8 [HiValueString text] =
  return $ HiValueBytes $ Encoding.encodeUtf8 text

evalFunction HiFunDecodeUtf8 [HiValueBytes bs] =
  case Encoding.decodeUtf8' bs of
    Right text -> return $ HiValueString text
    Left _     -> return HiValueNull

evalFunction HiFunZip [HiValueBytes bs] =
  return $ HiValueBytes $ BSL.toStrict $ Zlib.compressWith Zlib.defaultCompressParams { Zlib.compressLevel = Zlib.bestCompression } $ BSL.fromStrict bs

evalFunction HiFunUnzip [HiValueBytes bs] =
  return $ HiValueBytes $ BSL.toStrict $ Zlib.decompress $ BSL.fromStrict bs

evalFunction HiFunSerialise [value] =
  return $ HiValueBytes $ BSL.toStrict $ Serialise.serialise value

evalFunction HiFunDeserialise [HiValueBytes bs] =
  case Serialise.deserialiseOrFail $ BSL.fromStrict bs of
    Right value -> return value
    Left _      -> throwError HiErrorInvalidArgument

evalFunction HiFunRead [HiValueString path] =
  return $ HiValueAction (HiActionRead (Text.unpack path))

evalFunction HiFunWrite [HiValueString path, HiValueString content] =
  return $ HiValueAction (HiActionWrite (Text.unpack path) (Encoding.encodeUtf8 content))

evalFunction HiFunMkDir [HiValueString path] =
  return $ HiValueAction (HiActionMkDir (Text.unpack path))

evalFunction HiFunChDir [HiValueString path] =
  return $ HiValueAction (HiActionChDir (Text.unpack path))

evalFunction HiFunParseTime [HiValueString timeStr] =
  case readMaybe (Text.unpack timeStr) :: Maybe UTCTime of
    Just utcTime -> return $ HiValueTime utcTime
    Nothing      -> throwError HiErrorInvalidArgument

evalFunction HiFunRand [HiValueNumber from, HiValueNumber to] = do
  intFrom <- rationalToIntM from
  intTo <- rationalToIntM to
  if intFrom <= intTo
    then return $ HiValueAction (HiActionRand intFrom intTo)
    else throwError HiErrorInvalidArgument


evalFunction HiFunInvert [HiValueDict dict] = do
  let inverted = Map.foldrWithKey (\k v acc ->
                    Map.insertWith (<>) v (Seq.singleton k) acc
                  ) Map.empty dict
  return $ HiValueDict $ fmap HiValueList inverted

evalFunction HiFunCount [HiValueString txt] =
  return $ HiValueDict $ Map.map HiValueNumber $ countMap (HiValueString . Text.singleton) (Text.unpack txt)

evalFunction HiFunCount [HiValueList lst] =
  return $ HiValueDict $ Map.map HiValueNumber $ countMap id (toList lst)

evalFunction HiFunCount [HiValueBytes bs] =
  return $ HiValueDict $ Map.map HiValueNumber $ countMap (HiValueNumber . toRational) (BS.unpack bs)

evalFunction HiFunEcho [HiValueString s] =
  return $ HiValueAction (HiActionEcho s)

evalFunction _ _ = throwError HiErrorInvalidArgument

{- |
Helper for fold.
-}
applyBinary :: HiMonad m => HiFun -> HiValue -> HiValue -> ExceptT HiError m HiValue
applyBinary f x y = evalFunction f [x, y]


{- |
Processes multiplication with a given multiplier (`times`).
Supports strings, lists and byte arrays.
-}
processMul :: HiMonad m => HiValue -> Int -> ExceptT HiError m HiValue
processMul x times
  | times < 0 = throwError HiErrorInvalidArgument
  | otherwise = case x of
      HiValueString s -> return $ HiValueString (stimes times s)
      HiValueList xs  -> return $ HiValueList (stimes times xs)
      HiValueBytes xs  -> return $ HiValueBytes (stimes times xs)
      _               -> throwError HiErrorInvalidArgument

