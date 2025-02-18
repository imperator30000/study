{-# LANGUAGE OverloadedStrings #-}
import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply, HiExprDict),
                 HiValue(HiValueDict, HiValueString, HiValueNumber, HiValueList, HiValueBool, HiValueNull, HiValueFunction),
                 HiFun(HiFunCount, HiFunKeys, HiFunValues, HiFunInvert),
                 HiError(HiErrorInvalidArgument))
import HW5.Evaluator (eval)
import Test.Hspec (hspec, describe, it, shouldBe)
import qualified Data.Map.Strict as Map
import qualified Data.Sequence as Seq
import qualified Data.List as List
import Data.Foldable (toList)
import Data.Text (pack)
import Data.Ratio ((%))
import TestTH (evalIdentity, render)

normalizeValue :: HiValue -> HiValue
normalizeValue (HiValueList xs) = HiValueList (Seq.fromList (List.sort (toList xs)))
normalizeValue other            = other

shouldBeMap :: Map.Map HiValue HiValue -> Map.Map HiValue HiValue -> IO ()
shouldBeMap actual expected = 
  let normalizeMap = Map.map normalizeValue
  in List.sort (Map.toList (normalizeMap actual)) `shouldBe` List.sort (Map.toList (normalizeMap expected))



main :: IO ()
main = hspec $ do
  describe "Parser" $ do
    it "parses dictionary literals" $ do
      parse "{ \"width\": 120, \"height\": 80 }" `shouldBe`
        Right (HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                          , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                          ])
      parse "{ 1: true, 3: true, 4: false }" `shouldBe`
        Right (HiExprDict [ (HiExprValue (HiValueNumber 1), HiExprValue (HiValueBool True))
                          , (HiExprValue (HiValueNumber 3), HiExprValue (HiValueBool True))
                          , (HiExprValue (HiValueNumber 4), HiExprValue (HiValueBool False))
                          ])

    it "parses function calls for keys, values, count, invert" $ do
      parse "keys({ \"width\": 120, \"height\": 80 })" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunKeys))
               [HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                           , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                           ]])
      parse "values({ \"width\": 120, \"height\": 80 })" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunValues))
               [HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                           , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                           ]])
      parse "count(\"Hello World\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunCount))
               [HiExprValue (HiValueString "Hello World")])

    it "parses dot access for dictionary fields" $ do
      parse "{ \"width\": 120, \"height\": 80 }.width" `shouldBe`
        Right (HiExprApply
                (HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                            , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                            ])
                [HiExprValue (HiValueString "width")])

  describe "Evaluator" $ do
    it "evaluates dictionary key access" $ do
      evalIdentity (HiExprApply
                    (HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                                , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                                ])
                    [HiExprValue (HiValueString "width")])
        `shouldBe` Right (HiValueNumber 120)

      evalIdentity (HiExprApply
                    (HiExprDict [ (HiExprValue (HiValueString "key"), HiExprValue (HiValueBool True)) ])
                    [HiExprValue (HiValueString "unknown")])
        `shouldBe` Right HiValueNull

    it "evaluates keys and values functions" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunKeys))
                    [HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                                , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                                ]])
        `shouldBe` Right (HiValueList (Seq.fromList [HiValueString "height", HiValueString "width"]))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunValues))
                    [HiExprDict [ (HiExprValue (HiValueString "width"), HiExprValue (HiValueNumber 120))
                                , (HiExprValue (HiValueString "height"), HiExprValue (HiValueNumber 80))
                                ]])
        `shouldBe` Right (HiValueList (Seq.fromList [HiValueNumber 80, HiValueNumber 120]))

    it "evaluates count for string, bytes, and list" $ do
      let result = evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunCount))
                           [HiExprValue (HiValueString "XXXOX")])
      case result of
        Right (HiValueDict dict) -> dict `shouldBeMap` Map.fromList [(HiValueString "X", HiValueNumber 4), (HiValueString "O", HiValueNumber 1)]
        _ -> error "Expected HiValueDict"

      let resultList = evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunCount))
                                 [HiExprValue (HiValueList (Seq.fromList [HiValueBool True, HiValueBool False, HiValueBool True]))])
      case resultList of
        Right (HiValueDict dict) -> dict `shouldBeMap` Map.fromList [(HiValueBool True, HiValueNumber 2), (HiValueBool False, HiValueNumber 1)]
        _ -> error "Expected HiValueDict"

    it "evaluates invert" $ do
      let result = evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunInvert))
                           [HiExprDict [ (HiExprValue (HiValueString "x"), HiExprValue (HiValueNumber 1))
                                       , (HiExprValue (HiValueString "y"), HiExprValue (HiValueNumber 2))
                                       , (HiExprValue (HiValueString "z"), HiExprValue (HiValueNumber 1))
                                       ]])
      case result of
        Right (HiValueDict dict) -> 
          dict `shouldBeMap` Map.fromList [(HiValueNumber 1, HiValueList (Seq.fromList [HiValueString "x", HiValueString "z"])),
                                           (HiValueNumber 2, HiValueList (Seq.fromList [HiValueString "y"]))]
        _ -> error "Expected HiValueDict"

    it "returns null if key is not found" $ do
      evalIdentity (HiExprApply
                    (HiExprDict [ (HiExprValue (HiValueString "key"), HiExprValue (HiValueNumber 42)) ])
                    [HiExprValue (HiValueString "missing")])
        `shouldBe` Right HiValueNull

    it "throws error on invalid argument type" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunCount))
                    [HiExprValue (HiValueNumber 123)])
        `shouldBe` Left HiErrorInvalidArgument