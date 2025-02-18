{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Main (main) where

import HW5.Parser (parse)
import HW5.Evaluator (eval)
import HW5.Pretty (prettyValue)
import HW5.Base (HiExpr(..), HiError(..), HiValue(..))
import HW5.Action (HIO(..), HiPermission(..))
import Prettyprinter.Render.Terminal (putDoc)
import System.Console.Haskeline (InputT, runInputT, defaultSettings, getInputLine, outputStrLn)
import Data.Set (fromList)
import Control.Monad.IO.Class (liftIO)

main :: IO ()
main = runInputT defaultSettings repl

repl :: InputT IO ()
repl = do
  outputStrLn "Welcome to the Hi language REPL! Type ':quit' to exit."
  let loop = do
        maybeInput <- getInputLine "\nhi> "
        case maybeInput of
          Nothing -> return ()
          Just ":quit" -> outputStrLn "Goodbye!" >> return ()
          Just input -> do
            handleInput input
            loop
  loop

handleInput :: String -> InputT IO ()
handleInput input
  | null (words input) = return ()
  | ":parse" `elem` words input = handleParseCommand input
  | otherwise = handleEvalCommand input

handleParseCommand :: String -> InputT IO ()
handleParseCommand input = 
  case drop 1 (words input) of
    [] -> outputStrLn "Usage: :parse <expression>"
    exprWords -> 
      case parse (unwords exprWords) of
        Left err -> outputStrLn $ "Parse error: " ++ show err
        Right expr -> outputStrLn $ "Parsed expression: " ++ show expr

handleEvalCommand :: String -> InputT IO ()
handleEvalCommand input = 
  case parse input of
    Left err -> outputStrLn $ "Parse error: " ++ show err
    Right expr -> do
      result <- liftIO $ evalWithHIO expr
      case result of
        Left evalErr -> outputStrLn $ "Evaluation error: " ++ show evalErr
        Right value -> do
          liftIO $ putDoc (prettyValue value)
          outputStrLn ""

evalWithHIO :: HiExpr -> IO (Either HiError HiValue)
evalWithHIO expr = runHIO (eval expr) (fromList [AllowRead, AllowWrite, AllowTime])