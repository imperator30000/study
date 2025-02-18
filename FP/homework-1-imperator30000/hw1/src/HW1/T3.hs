module HW1.T3
  ( Tree (..)
  , tsize
  , tdepth
  , tmember
  , tinsert
  , tFromList
  ) where

type Meta = (Int, Int)

data Tree a = Leaf | Branch Meta (Tree a) a (Tree a)
  deriving (Show)

mkBranch :: Tree a -> a -> Tree a -> Tree a
mkBranch l x r = Branch ((1 + tsize l + tsize r), (1 + max (tdepth l) (tdepth r) )) l x r

tsize :: Tree a -> Int
tsize Leaf = 0
tsize (Branch (size, _) _ _ _) = size

tdepth :: Tree a -> Int
tdepth Leaf = 0
tdepth (Branch (_, depth) _ _ _) = depth


difdepth :: Tree a -> Int
difdepth Leaf = 0
difdepth (Branch _ l _ r) = (tdepth l) - (tdepth r)

rotateRight ::  Tree a -> Tree a
rotateRight Leaf = Leaf
rotateRight (Branch _ (Branch _ l1 x1 r1) x r) = mkBranch l1 x1 (mkBranch r1 x r)
rotateRight tree = tree


rotateLeft :: Tree a -> Tree a
rotateLeft Leaf = Leaf
rotateLeft (Branch _ l x (Branch _ l2 x2 r2)) = mkBranch (mkBranch l x l2) x2 r2
rotateLeft tree = tree

rotateLeftRight :: Tree a -> Tree a
rotateLeftRight (Branch _ l x r) = rotateRight(mkBranch (rotateLeft l) x r)
rotateLeftRight tree = tree


rotateRightLeft :: Tree a -> Tree a
rotateRightLeft (Branch _ l x r) = rotateLeft $ mkBranch l x (rotateRight r)
rotateRightLeft tree = tree


balance :: Tree a -> Tree a
balance t@(Branch _ l _ r)
  | difdepth t > 1 && difdepth l >= 0 = rotateRight t
  | difdepth t > 1 && difdepth l < 0  = rotateLeftRight t
  | difdepth t < -1 && difdepth r <= 0 = rotateLeft t
  | difdepth t < -1 && difdepth r > 0  = rotateRightLeft t
  | otherwise = t
balance tree = tree

-- Uncomment this function signature to implement this function.
-- The correct signature is commented to avoid compilation failure
-- with '-Werror' in the template project.
--
-- tmember :: Ord a => a -> Tree a -> Bool
tmember :: Ord a => a -> Tree a -> Bool
tmember _ Leaf = False
tmember x (Branch _ l y r)
  | x < y = tmember x l
  | x > y = tmember x r
  | otherwise = True


-- Uncomment this function signature to implement this function.
-- The correct signature is commented to avoid compilation failure
-- with '-Werror' in the template project.
--
-- tinsert :: Ord a => a -> Tree a -> Tree a
tinsert :: Ord a => a -> Tree a -> Tree a
tinsert x Leaf = mkBranch Leaf x Leaf
tinsert x tree@(Branch (_, _) l y r)
  | x < y     = balance(mkBranch (tinsert x l) y r)
  | x > y     = balance(mkBranch l y (tinsert x r))
  | otherwise = tree

-- Uncomment this function signature to implement this function.
-- The correct signature is commented to avoid compilation failure
-- with '-Werror' in the template project.
--
-- tFromList :: Ord a => [a] -> Tree a
tFromList :: Ord a => [a] -> Tree a
tFromList = foldr tinsert Leaf
