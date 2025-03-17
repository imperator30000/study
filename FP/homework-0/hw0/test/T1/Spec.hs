{-# LANGUAGE TypeOperators #-}

module T1.Spec (spec) where

import Test.Hspec
import HW0.T1

spec :: Spec
spec = do
  describe "distrib" $ do
    it "distributes Left into both components" $ do
      distrib (Left "error" :: Either String (Int, Bool))
        `shouldBe` (Left "error", Left "error")
    it "distributes Right into separate components" $ do
      distrib (Right (42, True) :: Either String (Int, Bool))
        `shouldBe` (Right 42, Right True)

  describe "flipIso" $ do
    it "correctly flips an Iso and applies it" $ do
      let iso = Iso (+1) (subtract 1)
      let flipped = flipIso iso
      runIso flipped 2 `shouldBe` 1  -- flipped performs the reverse operation

  describe "runIso" $ do
    it "applies the forward direction of the iso" $ do
      let iso = Iso (*2) (`div` 2)
      runIso iso 3 `shouldBe` 6  -- applies the forward direction of the iso

  describe "assocPair" $ do
    it "converts (a, (b, c)) to ((a, b), c)" $ do
      runIso assocPair (1, (2, 3)) `shouldBe` ((1, 2), 3 :: Int)
    it "converts ((a, b), c) back to (a, (b, c))" $ do
      runIso (flipIso assocPair) ((1, 2), 3) `shouldBe` (1, (2, 3 :: Int))

  describe "assocEither" $ do
    it "converts Either a (Either b c) to Either (Either a b) c" $ do
      runIso assocEither (Left "error" :: Either String (Either Int Bool))
        `shouldBe` Left (Left "error")
      runIso assocEither (Right (Left 42) :: Either String (Either Int Bool))
        `shouldBe` Left (Right 42)
      runIso assocEither (Right (Right True) :: Either String (Either Int Bool))
        `shouldBe` Right True
    it "converts Either (Either a b) c back to Either a (Either b c)" $ do
      runIso (flipIso assocEither) (Left (Left "error") :: Either (Either String Int) Bool)
        `shouldBe` Left "error"
      runIso (flipIso assocEither) (Left (Right 42) :: Either (Either String Int) Bool)
        `shouldBe` Right (Left 42)
      runIso (flipIso assocEither) (Right True :: Either (Either String Int) Bool)
        `shouldBe` Right (Right True)