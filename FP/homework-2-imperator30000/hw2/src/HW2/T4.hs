module HW2.T4
  ( DotString (..)
  , Fun (..)
  , Inclusive (..)
  , ListPlus (..)
  ) where

data ListPlus a = a :+ ListPlus a | Last a
  deriving (Show, Eq)

infixr 5 :+

instance Semigroup (ListPlus a) where
  (Last x) <> ys = x :+ ys
  (x :+ xs) <> ys = x :+ (xs <> ys)

data Inclusive a b = This a | That b | Both a b
  deriving (Show, Eq)

-- You may necessary constraints here
instance (Semigroup a, Semigroup b) => Semigroup (Inclusive a b) where
  This a1 <> This a2 = This (a1 <> a2)
  That b1 <> That b2 = That (b1 <> b2)
  Both a1 b1 <> Both a2 b2 = Both (a1 <> a2) (b1 <> b2)
  This a  <> That b  = Both a b
  That b  <> This a  = Both a b
  This a  <> Both a2 b2 = Both (a <> a2) b2
  Both a1 b <> This a2 = Both (a1 <> a2) b
  That b  <> Both a2 b2 = Both a2 (b <> b2)
  Both a1 b <> That b2 = Both a1 (b <> b2)

newtype DotString = DS String
  deriving (Show, Eq)

instance Semigroup DotString where
  DS s1 <> DS s2
    | null s1 = DS s2
    | null s2 = DS s1
    | otherwise = DS (s1 ++ "." ++ s2)

instance Monoid DotString where
  mempty = DS ""

newtype Fun a = F (a -> a)

instance Semigroup (Fun a) where
  F f1 <> F f2 = F (f1 . f2)

instance Monoid (Fun a) where
  mempty = F id