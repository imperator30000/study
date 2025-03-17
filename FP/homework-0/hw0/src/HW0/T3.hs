module HW0.T3
  ( compose
  , contract
  , i
  , k
  , permute
  , s
  ) where

-- S = S
s :: (a -> b -> c) -> (a -> b) -> (a -> c)
s f g x = f x (g x)

-- K = K
k :: a -> b -> a
k x _ = x

-- I = S K K
i :: a -> a
i = s k k

-- B = S (K S) K
compose :: (b -> c) -> (a -> b) -> (a -> c)
compose = s (k s) k

-- W = S S (S K) = C S I
contract :: (a -> a -> b) -> (a -> b)
contract = permute s i

-- C = S (S (K (S (K S) K)) S) (K K) = S (B B S) (K K)
permute :: (a -> b -> c) -> (b -> a -> c)
permute = s (compose compose s) (k k)
