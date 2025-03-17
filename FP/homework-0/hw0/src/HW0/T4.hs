module HW0.T4
  ( fac
  , fib
  , map'
  , repeat'
  ) where

import Numeric.Natural (Natural)
import  Data.Function (fix)

repeat' :: a -> [a]
repeat' x = fix (x:)

map' :: (a -> b) -> [a] -> [b]
map' = fix (\g f lst -> case lst of
  []     -> []
  (x:xs) -> f x : g f xs)

fib :: Natural -> Natural
fib = fix (\_ n -> rec' 0 1 n)
  where
    rec' f1 f2 i
      | i == 0    = f1
      | otherwise = rec' f2 (f1 + f2) (i - 1)

fac :: Natural -> Natural
fac = fix (\self n -> 
  if n == 0 
  then 1
  else n * self (n - 1))
