module HW2.T2
  ( joinWith
  , splitOn
  ) where

import Data.List.NonEmpty (NonEmpty(..))

-- You may add necessary constraints here
splitOn :: Eq a => a -> [a] -> NonEmpty [a]
splitOn sep = foldr f ([] :| [])
  where
    f x (y :| ys)
      | x == sep  = [] :| (y : ys)
      | otherwise = (x : y) :| ys

joinWith :: a -> NonEmpty [a] -> [a]
joinWith sep (x :| xs) = x ++ foldr (\y acc -> sep : y ++ acc) [] xs
