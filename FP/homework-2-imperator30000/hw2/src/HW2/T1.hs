module HW2.T1
  ( Tree (..)
  , tfoldr
  ) where

data Tree a = Leaf | Branch Int (Tree a) a (Tree a)
  deriving (Show)

tfoldr :: (a -> b -> b) -> b -> Tree a -> b
tfoldr _ z Leaf = z
tfoldr f z (Branch _ left x right) = tfoldr f (f x (tfoldr f z right)) left

