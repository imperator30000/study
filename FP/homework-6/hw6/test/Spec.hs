{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE KindSignatures #-}

module Main (main) where

import Test.Hspec
import HW6.T1
import HW6.T2
import Control.Concurrent.Async (forConcurrently_)
import Data.Proxy (Proxy(..))
import Control.Monad (forM, forM_)

type ExampleSet = '[ "a", "b" ] :: TSet
type AddedSet = Add "c" ExampleSet
type DeletedSet = Delete "a" ExampleSet

main :: IO ()
main = hspec $ do
  describe "Task 1: Concurrent Hash Table" $ do
    it "allows basic insertion and lookup (Test 1)" $ do
      cht <- newCHT
      putCHT "key1" "value1" cht
      putCHT "key2" "value2" cht

      val1 <- getCHT "key1" cht
      val2 <- getCHT "key2" cht
      val3 <- getCHT "key3" cht

      val1 `shouldBe` Just "value1"
      val2 `shouldBe` Just "value2"
      val3 `shouldBe` Nothing

    it "resizes automatically when load factor exceeded (Test 2)" $ do
      cht <- newCHT
      let numInsertions :: Int
          numInsertions = 50

      forM_ [1 .. numInsertions] $ \i -> putCHT i ("value" ++ show i) cht

      allCorrect <- all id <$> forM [1 .. numInsertions] (\i -> do
        val <- getCHT i cht
        return (val == Just ("value" ++ show i)))

      allCorrect `shouldBe` True

    it "returns correct size after insertions (Test 3)" $ do
      cht <- newCHT
      let entries :: [(Int, String)]
          entries = [(1, "value1" :: String), (2, "value2"), (1, "newValue1")]

      forM_ entries $ \(k, v) -> putCHT k v cht

      size <- sizeCHT cht
      size `shouldBe` 2

    it "remains consistent under concurrent access (Test 4)" $ do
      cht <- newCHT

      let keys :: [Int]
          keys = [1 .. 1000]
          
      let tasks = keys ++ keys

      forConcurrently_ tasks $ \k -> putCHT k ("value" ++ show k) cht

      size <- sizeCHT cht
      size `shouldBe` length keys

  describe "Task 2: Type-level Set" $ do
    it "correctly checks if a type-level set contains an element (Test 5)" $ do
      let result1 = Proxy @(Contains "a" ExampleSet)
      let result2 = Proxy @(Contains "c" ExampleSet)
      let result3 = Proxy @(Contains "b" ExampleSet)

      result1 `shouldBe` Proxy @'True
      result2 `shouldBe` Proxy @'False
      result3 `shouldBe` Proxy @'True

    it "correctly adds new elements to the set (Test 6)" $ do
      let result = Proxy @AddedSet
      result `shouldBe` Proxy @'[ "a", "b", "c" ]

    it "correctly deletes elements from the set (Test 7)" $ do
      let result = Proxy @DeletedSet
      result `shouldBe` Proxy @'[ "b" ]