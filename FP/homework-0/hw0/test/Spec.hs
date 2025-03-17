module Main (main) where

import Test.Hspec
import qualified T1.Spec
import qualified T2.Spec

main :: IO ()
main = hspec $ do
  T1.Spec.spec 
  T2.Spec.spec 