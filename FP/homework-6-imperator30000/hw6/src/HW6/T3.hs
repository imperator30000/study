module HW6.T3
  ( Config (..)
  , Cell (..)
  , CellState (..)
  , Comonad19Grid
  
  , simulate
  , printGrid
  ) where

import System.Random (StdGen, randomR, mkStdGen)
import Data.Grid (Grid(..), left, right, up, down, gToList)
import Data.ListZipper (ListZipper(..))
import Control.Comonad (extract, extend)
import Control.Monad (liftM2)

data Config = Config
  { probability :: Double
  , incubationPeriod :: Int
  , illnessDuration :: Int
  , immunityDuration :: Int
  } deriving Show

data CellState
  = Healthy
  | Infected Int
  | Ill Int
  | Immune Int
  deriving Show

data Cell = Cell
  { cellState :: CellState
  , cellRand :: StdGen
  }

type Comonad19Grid = Grid Cell


neighbours :: [Grid a -> Grid a]
neighbours = horizontals ++ verticals ++ liftM2 (.) horizontals verticals
  where 
    horizontals = [left, right]
    verticals   = [up, down]

updateCell :: Config -> Grid Cell -> Cell
updateCell cfg g = case state of
    Healthy -> tryInfect cfg gen neighborsStates
    _       -> progressState cfg currentCell
  where
    currentCell@(Cell state gen) = extract g
    neighborsStates = map (cellState . extract . ($ g)) neighbours


decrementState :: Int -> CellState -> CellState
decrementState t (Infected _) = Infected (t - 1)
decrementState t (Ill _)      = Ill (t - 1)
decrementState t (Immune _)   = Immune (t - 1)
decrementState _ state        = state

applyTimer :: Int -> StdGen -> CellState -> (StdGen -> Cell) -> Cell
applyTimer t gen currentState nextState =
  if t > 1
  then Cell (decrementState t currentState) gen
  else nextState gen

progressState :: Config -> Cell -> Cell
progressState cfg (Cell (Infected t) gen) =
  applyTimer t gen (Infected t) (\gen' -> Cell (Ill (illnessDuration cfg)) gen')
progressState cfg (Cell (Ill t) gen) =
  applyTimer t gen (Ill t) (\gen' -> Cell (Immune (immunityDuration cfg)) gen')
progressState _ (Cell (Immune t) gen) =
  applyTimer t gen (Immune t) (\gen' -> Cell Healthy gen')
progressState _ cell = cell

tryInfect :: Config -> StdGen -> [CellState] -> Cell
tryInfect cfg gen neighborsStates =
    let (finalGen, infectionOccurred) = foldl checkNeighbor (gen, False) neighborsStates
    in if infectionOccurred
       then Cell (Infected (incubationPeriod cfg)) finalGen
       else Cell Healthy finalGen
  where
    checkNeighbor (curGen, infected) neighbor =
      let (rand, nextGen) = randomR (0.0, 1.0) curGen
      in if isInfectious neighbor && rand < probability cfg
         then (nextGen, True)
         else (nextGen, infected)

    isInfectious :: CellState -> Bool
    isInfectious (Infected _) = True
    isInfectious (Ill _)      = True
    isInfectious _            = False

step :: Config -> Comonad19Grid -> Comonad19Grid
step cfg = extend (updateCell cfg)

simulate :: Config -> Int -> [Comonad19Grid]
simulate config seed = iterate (step config) (initialGrid config seed)

mkCoordSeed :: Int -> Int -> Int -> StdGen
mkCoordSeed baseSeed x y = mkStdGen (baseSeed + 37 * x + 41 * y)

createInfiniteGrid :: (Int -> ListZipper a) -> ListZipper (ListZipper a)
createInfiniteGrid createRow =
    LZ (map createRow [-1, -2 ..]) (createRow 0) (map createRow [1..])

createInfiniteRow :: (Int -> a) -> ListZipper a
createInfiniteRow createCell =
    LZ (map createCell [-1, -2 ..]) (createCell 0) (map createCell [1..])

initialGrid :: Config -> Int -> Comonad19Grid
initialGrid config seed = 
    Grid $ createInfiniteGrid createRow
  where
    createRow y = createInfiniteRow (createCellAt y)

    createCellAt y x 
      | isCenter x y = Cell (Infected (incubationPeriod config)) (mkCoordSeed seed x y)
      | otherwise    = Cell Healthy (mkCoordSeed seed x y)

    isCenter x y = x == 0 && y == 0

filterGrid :: [[Char]] -> Int -> [[Char]]
filterGrid rows size
    | even size = drop 1 (map (drop 1) rows)
    | otherwise = rows

printGrid :: Comonad19Grid -> Int -> IO ()
printGrid grid size = mapM_ putStrLn $ filterGrid rows size
  where
    rows = gToList (fmap renderCell grid) (div size 2)
    renderCell (Cell Healthy _)      = '_'
    renderCell (Cell (Infected _) _) = 'i'
    renderCell (Cell (Ill _) _)      = '#'
    renderCell (Cell (Immune _) _)   = '@'