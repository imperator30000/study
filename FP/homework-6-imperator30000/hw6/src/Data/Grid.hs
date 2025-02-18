-- | This module defines 'Grid' datatype.
-- Feel free to define additional helper functions to work
-- with this datatype in this module.
module Data.Grid
  ( Grid (..)
  , up
  , down
  , left
  , right
  , gridWrite
  , gToList
  ) where

import Control.Comonad (Comonad (..))

import Data.ListZipper (ListZipper (..), listLeft, listRight, listWrite, toList, genericMove)

-- | 'Grid' is a two-dimensional zipper structure based on `ListZipper`. 
-- It enables efficient navigation and modification of elements in a grid-like
-- data structure, where navigation is performed row-wise and column-wise.
newtype Grid a = Grid { unGrid :: ListZipper (ListZipper a) }

-- | Move the focus one row up in the grid.
up :: Grid a -> Grid a
up   (Grid g) = Grid (listLeft  g)

-- | Move the focus one row down in the grid.
down :: Grid a -> Grid a
down (Grid g) = Grid (listRight g)  

-- | Move the focus one column to the left in the grid.
left :: Grid a -> Grid a
left  (Grid g) = Grid (fmap listLeft  g)

-- | Move the focus one column to the right in the grid.
right :: Grid a -> Grid a
right (Grid g) = Grid (fmap listRight g)

-- | Read the element at the current focus of the grid.
gridRead :: Grid a -> a
gridRead (Grid g) = extract $ extract g

-- | Write a new element to the current focus of the grid, replacing the old value.
gridWrite :: a -> Grid a -> Grid a
gridWrite x (Grid g) = Grid $ listWrite newLine g
  where
    oldLine = extract g
    newLine = listWrite x oldLine

-- | Convert the grid into a list of rows, where each row is represented as a list of elements.
-- The number of columns in each row is determined by the given integer `n`.
gToList :: Grid a -> Int -> [[a]]
gToList (Grid g) n = map (\row -> toList row n) (toList g n)

-- | A horizontal zipper that allows navigation within the row of the grid
-- by moving left and right.
horizontal :: Grid a -> ListZipper (Grid a)
horizontal = genericMove left right

-- | A vertical zipper that allows navigation between rows of the grid
-- by moving up and down.
vertical :: Grid a -> ListZipper (Grid a)
vertical   = genericMove up down

instance Functor Grid where
  fmap f (Grid g) = Grid (fmap (fmap f) g)

instance Comonad Grid where
  extract = gridRead

  duplicate = Grid . fmap horizontal . vertical
