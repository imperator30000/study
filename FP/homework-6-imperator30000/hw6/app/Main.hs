module Main (main) where

import HW6.T3 (Config(..), simulate, printGrid)
import Control.Exception (Exception, throwIO)
import Control.Monad (when)
import Options.Applicative

data ValidationError = ValidationError String 
  deriving (Show)
instance Exception ValidationError

data CLIOptions = CLIOptions
  { prob        :: Double
  , incub       :: Int
  , ill         :: Int
  , immun       :: Int
  , gridSize    :: Int
  , iterations  :: Int
  , seed        :: Int
  } deriving (Show)

cliOptionsParser :: Parser CLIOptions
cliOptionsParser = CLIOptions
  <$> option auto
      ( long "prob"
     <> metavar "DOUBLE"
     <> help "Infection probability (0 < p < 1)" )
  <*> option auto
      ( long "incub"
     <> metavar "INT"
     <> help "Incubation period duration" )
  <*> option auto
      ( long "ill"
     <> metavar "INT"
     <> help "Illness duration" )
  <*> option auto
      ( long "immun"
     <> metavar "INT"
     <> help "Immunity duration" )
  <*> option auto
      ( long "grid-size"
     <> metavar "INT"
     <> help "Output grid size (a square size)" )
  <*> option auto
      ( long "iterations"
     <> metavar "INT"
     <> help "Number of simulation iterations" )
  <*> option auto
      ( long "seed"
     <> metavar "INT"
     <> value 42
     <> help "Random seed for reproducibility (default: 42)" )

validatePositive :: String -> Int -> IO ()
validatePositive name val = 
  when (val <= 0) $
    throwIO $ ValidationError (name ++ " must be a positive integer greater than 0.")

validateProbability :: Double -> IO ()
validateProbability probValue = 
  when (probValue <= 0 || probValue > 1) $
    throwIO $ ValidationError "Probability (--prob) must be strictly between 0 and 1."


main :: IO ()
main = do
    cliOptions <- execParser opts

    validateProbability (prob cliOptions)
    validatePositive "Incubation period (--incub)" (incub cliOptions)
    validatePositive "Illness duration (--ill)" (ill cliOptions)
    validatePositive "Immunity duration (--immun)" (immun cliOptions)
    validatePositive "Grid size (--grid-size)" (gridSize cliOptions)
    validatePositive "Number of iterations (--iterations)" (iterations cliOptions)

    let config = Config
          { probability = prob cliOptions
          , incubationPeriod = incub cliOptions
          , illnessDuration = ill cliOptions
          , immunityDuration = immun cliOptions
          }

    let grids = simulate config (seed cliOptions)

    mapM_ (\(grid, i) -> do
            putStrLn $ "\nIteration " ++ show i ++ ":"
            printGrid grid (gridSize cliOptions)
          ) (zip grids [1..(iterations cliOptions)])
  where
    opts = info (cliOptionsParser <**> helper)
           ( fullDesc
          <> progDesc "Simulate Covid-19 spread on an infinite grid"
          <> header "Comonad-19 Simulator" )

