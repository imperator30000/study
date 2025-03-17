{-# LANGUAGE TypeOperators #-}

module T2.Spec (spec) where

import Test.Hspec
import HW0.T2
import Data.Void (Void)

spec :: Spec
spec = do
  describe "doubleNeg" $ do
    -- Негативный сценарий
    it "fails when trying to actually invoke the passed function (negative test)" $ do
      let f :: Int -> Void
          f = error "Should not be called"
      doubleNeg (101 :: Int) f `shouldBe` (error "Should not be called")

    -- Позитивный сценарий
    it "ensures double negation works logically (positive test)" $ do
      let doubleNegation :: Not (Not Int)
          doubleNegation = doubleNeg (42 :: Int)
      -- Создаём функцию notInt :: Int -> Void
      let notInt :: Not Int
          notInt x = error $ "Should not exist: " ++ show x
      -- Применение doubleNegation с notInt выбросит ожидаемую ошибку
      doubleNegation notInt `shouldBe` (error "Should not exist: 42")

  describe "reduceTripleNeg" $ do
    -- Негативный сценарий
    it "fails when trying to actually invoke the passed function (negative test)" $ do
      let f :: Not (Not Int) -> Void
          f g = g (\x -> error "Should not be used: " ++ show x)
      let tripleNegation :: Not (Not (Not Int))
          tripleNegation f = f (\g -> g (\x -> error $ "Should not be used: " ++ show x))
      reduceTripleNeg tripleNegation (\x -> error $ "Should not exist: " ++ show x)
        `shouldBe` (error "Should not exist: 1337")

    -- Позитивный сценарий
    it "ensures triple negation reduces correctly to single negation (positive test)" $ do
      let tripleNegation :: Not (Not (Not Int))
          tripleNegation f = f (\g -> g (\x -> error $ "Unused value: " ++ show x))
      let singleNegation :: Not Int
          singleNegation = reduceTripleNeg tripleNegation
      -- Применение singleNegation выбросит ожидаемую ошибку
      singleNegation (\x -> error $ "Unused value: " ++ show x)
        `shouldBe` (error "Unused value: <some value>")