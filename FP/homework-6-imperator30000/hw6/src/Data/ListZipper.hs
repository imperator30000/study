-- | This module defines 'ListZipper' datatype.
-- Feel free to define additional helper functions to work
-- with this datatype in this module.
module Data.ListZipper
  ( ListZipper (..)
  , listLeft
  , listRight
  , listWrite
  , toList
  , genericMove
  ) where

import Control.Comonad (Comonad (..))

-- | A 'ListZipper' is a focusable list.
data ListZipper a = LZ [a] a [a]

-- | Move one position to the left in the `ListZipper`.
listLeft :: ListZipper a -> ListZipper a
listLeft  (LZ (a:as) x bs) = LZ as a (x:bs)
listLeft _ = error "listLeft"

-- | Move one position to the right in the `ListZipper`.
listRight :: ListZipper a -> ListZipper a
listRight (LZ as x (b:bs)) = LZ (x:as) b bs
listRight _ = error "listRight"

-- | Replace the current focus with a new value.
listWrite :: a -> ListZipper a -> ListZipper a
listWrite x (LZ ls _ rs) = LZ ls x rs

-- | Convert a `ListZipper` into a regular list, including a limited number of elements to
toList :: ListZipper a -> Int -> [a]
toList (LZ ls x rs) n = reverse (take n ls) ++ [x] ++ take n rs

instance Functor ListZipper where
  fmap f (LZ ls x rs) = LZ (map f ls) (f x) (map f rs)

-- | A helper function that creates an infinite list by repeatedly applying 
-- the given function to a value (excluding the initial value).
iterateTail :: (a -> a) -> a -> [a]
iterateTail f = tail . iterate f

-- | A generic function to produce a `ListZipper` by repeatedly applying 
-- two transformation functions (`f` and `g`) to generate the left and right lists.
genericMove :: (z a -> z a)
            -> (z a -> z a)
            -> z a
            -> ListZipper (z a)
genericMove f g e = LZ (iterateTail f e) e (iterateTail g e)


instance Comonad ListZipper where
  extract (LZ _ x _) = x

  duplicate = genericMove listLeft listRight

  extend = undefined

