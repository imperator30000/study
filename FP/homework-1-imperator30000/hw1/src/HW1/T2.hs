module HW1.T2
  ( N (..)
  , nplus
  , nmult
  , nsub
  , nFromNatural
  , nToNum
  , ncmp
  , nEven
  , nOdd
  , ndiv
  , nmod
  ) where

import Numeric.Natural

data N = Z | S N
  deriving (Show, Eq)

nplus :: N -> N -> N
nplus Z n = n
nplus (S m) n = S (nplus n m)

nmult :: N -> N -> N
nmult Z _ = Z
nmult (S m) n = nplus n (nmult m n)

nsub :: N -> N -> Maybe N
nsub n Z = Just n
nsub Z _ = Nothing
nsub (S m) (S n) = nsub m n

ncmp :: N -> N -> Ordering
ncmp Z Z = EQ
ncmp (S _) Z = GT
ncmp Z (S _) = LT
ncmp (S m) (S n) = ncmp m n

nFromNatural :: Natural -> N
nFromNatural 0 = Z
nFromNatural n = S (nFromNatural (n - 1))

-- Uncomment this function signature to implement this function.
-- The correct signature is commented to avoid compilation failure
-- with '-Werror' in the template project.
--
-- nToNum :: Num a => N -> a
nToNum :: Num a => N -> a
nToNum Z     = 0
nToNum (S n) = 1 + nToNum n

nEven :: N -> Bool
nEven Z = True
nEven (S n) = nOdd n

nOdd :: N -> Bool
nOdd Z = False
nOdd (S n) = nEven n

ndiv :: N -> N -> N
ndiv _ Z = error "Division by zero"
ndiv m n = case nsub m n of
             Just r  -> S (ndiv r n)
             Nothing -> Z

nmod :: N -> N -> N
nmod _ Z = error "Modulo by zero"
nmod m n = case nsub m n of
             Just r  -> nmod r n
             Nothing -> m
