module HW0.T5
  ( Nat
  , nFromNatural
  , nmult
  , nplus
  , ns
  , nToNum
  , nz
  ) where

import Numeric.Natural

type Nat a = (a -> a) -> a -> a

nz :: Nat a
nz _ x = x

ns :: Nat a -> Nat a
ns n f x = f (n f x)

nplus :: Nat a -> Nat a -> Nat a
nplus n m f x = n f (m f x)

nmult :: Nat a -> Nat a -> Nat a
nmult n m f = n (m f)

nFromNatural :: Natural -> Nat a
nFromNatural 0 = nz
nFromNatural n = ns (nFromNatural (n - 1))


nToNum :: Num a => Nat a -> a
nToNum n = n (+1) 0
