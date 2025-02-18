{-# LANGUAGE TypeOperators #-}

module HW0.T1
  ( type (<->) (Iso)
  , assocEither
  , assocPair
  , distrib
  , flipIso
  , runIso
  ) where

data a <-> b = Iso (a -> b) (b -> a)

distrib :: Either a (b, c) -> (Either a b, Either a c)
distrib = undefined

flipIso :: (a <-> b) -> (b <-> a)
flipIso = undefined

runIso :: (a <-> b) -> (a -> b)
runIso = undefined

assocPair :: (a, (b, c)) <-> ((a, b), c)
assocPair = undefined

assocEither :: Either a (Either b c) <-> Either (Either a b) c
assocEither = undefined
