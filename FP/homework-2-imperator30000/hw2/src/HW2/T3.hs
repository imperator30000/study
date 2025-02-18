module HW2.T3
  ( epart
  , mcat
  ) where

-- You may add necessary constraints here.
mcat :: Monoid a => [Maybe a] -> a
mcat = foldMap (maybe mempty id)

-- You may add necessary constraints here.
epart :: (Monoid a, Monoid b) => [Either a b] -> (a, b)
epart = foldMap epartHelper
  where
    epartHelper (Left x)  = (x, mempty)
    epartHelper (Right y) = (mempty, y)
