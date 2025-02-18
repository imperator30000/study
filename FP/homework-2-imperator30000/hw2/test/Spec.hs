module Main (main) where

import Test.Hspec
import HW2.T1 (Tree(..), tfoldr)
import HW2.T2 (splitOn, joinWith)
import HW2.T3 (mcat, epart)
import HW2.T4 (ListPlus(..), DotString(..), Inclusive(..), Fun(..))

import Data.List.NonEmpty (NonEmpty(..))
import Data.Monoid (Sum(Sum))

main :: IO ()
main = hspec $ do
  describe "HW2.T1" $ do
    it "tfoldr on Tree" $ do
      let tree :: Tree Int
          tree = Branch 1 (Branch 2 Leaf 3 Leaf) 4 (Branch 3 Leaf 5 Leaf)
      tfoldr (+) 0 tree `shouldBe` 12
      tfoldr (*) 1 tree `shouldBe` 60

  describe "HW2.T2" $ do
    it "splitOn separates by the given separator" $ do
      splitOn ',' "a,b,c" `shouldBe` ("a" :| ["b", "c"])

    it "joinWith combines list with separator" $ do
      joinWith ',' ("a" :| ["b", "c"]) `shouldBe` "a,b,c"

  describe "HW2.T3" $ do
    it "mcat combines list of Maybe values" $ do
      mcat [Just (Sum (1 :: Int)), Nothing, Just (Sum 5)] `shouldBe` Sum 6
      mcat [Nothing, Nothing] `shouldBe` Sum (0 :: Int)

    it "epart splits Either values into a pair" $ do
      epart [Left "left", Right "right", Left "again"] `shouldBe` ("leftagain", "right")

  describe "HW2.T4" $ do
    it "ListPlus concatenation works" $ do
      (Last (1 :: Int) <> (2 :+ Last 3)) `shouldBe` (1 :+ 2 :+ Last 3)

    it "DotString concatenation works" $ do
      (DS "test" <> DS "string") `shouldBe` DS "test.string"
      (DS "single" <> DS "") `shouldBe` DS "single"

    it "Inclusive works with semigroups" $ do
      (This "a" <> That "b") `shouldBe` Both "a" "b"
      (Both "left" "1" <> Both "Right" "2") `shouldBe` Both "leftRight" "12"

    it "Fun composition works" $ do
      let fun1 = F (+1)
          fun2 = F (*2)
          F composed = fun1 <> fun2
      composed (3 :: Int) `shouldBe` 7