import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply))
import HW5.Base (HiValue(HiValueNumber, HiValueFunction, HiValueList))
import HW5.Base (HiFun(HiFunList, HiFunRange, HiFunFold, HiFunAdd, HiFunMul, HiFunReverse, HiFunLength))
import HW5.Base (HiError(HiErrorInvalidArgument, HiErrorArityMismatch, HiErrorInvalidFunction))
import Test.Hspec (hspec, describe, it, shouldBe)
import Data.Sequence (fromList)
import Data.Ratio ((%))
import TestTH (evalIdentity, render)

main :: IO ()
main = hspec $ do
  describe "Parser" $ do
    it "parses list literals " $ do
      parse "[1, 2, 3]" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunList))
              [HiExprValue (HiValueNumber (1 % 1)),
               HiExprValue (HiValueNumber (2 % 1)),
               HiExprValue (HiValueNumber (3 % 1))])

    it "parses empty list" $ do
      parse "[]" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunList)) [])

    it "parses fold" $ do
      parse "fold(add, [1, 2, 3])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunFold))
              [HiExprValue (HiValueFunction HiFunAdd),
               HiExprApply (HiExprValue (HiValueFunction HiFunList))
                 [HiExprValue (HiValueNumber (1 % 1)),
                  HiExprValue (HiValueNumber (2 % 1)),
                  HiExprValue (HiValueNumber (3 % 1))]])

    it "parses range" $ do
      parse "range(1, 5)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunRange))
              [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (5 % 1))])

  describe "Evaluator" $ do
    it "evaluates list literals" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunList))
                 [HiExprValue (HiValueNumber (1 % 1)),
                  HiExprValue (HiValueNumber (2 % 1)),
                  HiExprValue (HiValueNumber (3 % 1))])
        `shouldBe` Right (HiValueList $ fromList [HiValueNumber (1 % 1), HiValueNumber (2 % 1), HiValueNumber (3 % 1)])

    it "evaluates empty list" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunList)) [])
        `shouldBe` Right (HiValueList $ fromList [])

    it "evaluates range" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunRange))
                 [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (5 % 1))])
        `shouldBe` Right (HiValueList $ fromList [HiValueNumber (1 % 1),
                                                  HiValueNumber (2 % 1),
                                                  HiValueNumber (3 % 1),
                                                  HiValueNumber (4 % 1),
                                                  HiValueNumber (5 % 1)])

    it "evaluates fold with add" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunFold))
                 [HiExprValue (HiValueFunction HiFunAdd),
                  HiExprApply (HiExprValue (HiValueFunction HiFunList))
                    [HiExprValue (HiValueNumber (1 % 1)),
                     HiExprValue (HiValueNumber (2 % 1)),
                     HiExprValue (HiValueNumber (3 % 1))]])
        `shouldBe` Right (HiValueNumber (6 % 1))
        
    it "evaluates fold with multiplication" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunFold))
                 [HiExprValue (HiValueFunction HiFunMul),
                  HiExprApply (HiExprValue (HiValueFunction HiFunList))
                    [HiExprValue (HiValueNumber (2 % 1)),
                     HiExprValue (HiValueNumber (3 % 1)),
                     HiExprValue (HiValueNumber (4 % 1))]])
        `shouldBe` Right (HiValueNumber (24 % 1))

    it "evaluates length of a list" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunLength))
                 [HiExprApply (HiExprValue (HiValueFunction HiFunList))
                  [HiExprValue (HiValueNumber (1 % 1)),
                   HiExprValue (HiValueNumber (2 % 1)),
                   HiExprValue (HiValueNumber (3 % 1))]])
        `shouldBe` Right (HiValueNumber (3 % 1))

    it "evaluates reverse of a list" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunReverse))
                 [HiExprApply (HiExprValue (HiValueFunction HiFunList))
                  [HiExprValue (HiValueNumber (1 % 1)),
                   HiExprValue (HiValueNumber (2 % 1)),
                   HiExprValue (HiValueNumber (3 % 1))]])
        `shouldBe` Right (HiValueList $ fromList [HiValueNumber (3 % 1),
                                                  HiValueNumber (2 % 1),
                                                  HiValueNumber (1 % 1)])

    it "evaluates list concatenation" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                 [HiExprApply (HiExprValue (HiValueFunction HiFunList))
                  [HiExprValue (HiValueNumber (1 % 1)),
                   HiExprValue (HiValueNumber (2 % 1))],
                  HiExprApply (HiExprValue (HiValueFunction HiFunList))
                  [HiExprValue (HiValueNumber (3 % 1)),
                   HiExprValue (HiValueNumber (4 % 1))]])
        `shouldBe` Right (HiValueList $ fromList [HiValueNumber (1 % 1),
                                                  HiValueNumber (2 % 1),
                                                  HiValueNumber (3 % 1),
                                                  HiValueNumber (4 % 1)])

    it "evaluates list repetition" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunMul))
                 [HiExprApply (HiExprValue (HiValueFunction HiFunList))
                  [HiExprValue (HiValueNumber (1 % 1)),
                   HiExprValue (HiValueNumber (2 % 1))],
                  HiExprValue (HiValueNumber (3 % 1))])
        `shouldBe` Right (HiValueList $ fromList [HiValueNumber (1 % 1),
                                                  HiValueNumber (2 % 1),
                                                  HiValueNumber (1 % 1),
                                                  HiValueNumber (2 % 1),
                                                  HiValueNumber (1 % 1),
                                                  HiValueNumber (2 % 1)])

    it "evaluates list indexing" $ do
      evalIdentity (HiExprApply (HiExprApply (HiExprValue (HiValueFunction HiFunList))
                       [HiExprValue (HiValueNumber (1 % 1)),
                        HiExprValue (HiValueNumber (2 % 1)),
                        HiExprValue (HiValueNumber (3 % 1))])
                  [HiExprValue (HiValueNumber (1 % 1))])
        `shouldBe` Right (HiValueNumber (2 % 1))

    it "evaluates list slicing" $ do
      evalIdentity (HiExprApply (HiExprApply (HiExprValue (HiValueFunction HiFunList))
                       [HiExprValue (HiValueNumber (1 % 1)),
                        HiExprValue (HiValueNumber (2 % 1)),
                        HiExprValue (HiValueNumber (3 % 1))])
                  [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (3 % 1))])
        `shouldBe` Right (HiValueList $ fromList [HiValueNumber (2 % 1), HiValueNumber (3 % 1)])

    it "handles errors" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunRange))
                 [HiExprValue (HiValueList $ fromList []), HiExprValue (HiValueNumber (5 % 1))])
        `shouldBe` Left HiErrorInvalidArgument

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunRange))
                 [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueFunction HiFunAdd)])
        `shouldBe` Left HiErrorInvalidArgument

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunRange))
                 [HiExprValue (HiValueNumber (1 % 1))])
        `shouldBe` Left HiErrorArityMismatch

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunFold))
                 [HiExprValue (HiValueFunction HiFunAdd)])
        `shouldBe` Left HiErrorArityMismatch

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunList))
                 [])
        `shouldBe` Right (HiValueList $ fromList [])

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunReverse))
                 [])
        `shouldBe` Left HiErrorArityMismatch
    
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunFold))
                 [HiExprValue (HiValueFunction HiFunAdd),
                  HiExprValue (HiValueNumber (42 % 1))])
        `shouldBe` Left HiErrorInvalidArgument

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunReverse))
                 [HiExprValue (HiValueNumber (10 % 1))])
        `shouldBe` Left HiErrorInvalidArgument

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                 [HiExprValue (HiValueNumber (1 % 1)),
                  HiExprApply (HiExprValue (HiValueFunction HiFunList))
                  [HiExprValue (HiValueNumber (2 % 1))]])
        `shouldBe` Left HiErrorInvalidArgument

      evalIdentity (HiExprApply (HiExprApply (HiExprValue (HiValueFunction HiFunList))
                       [HiExprValue (HiValueNumber (1 % 1)),
                        HiExprValue (HiValueNumber (2 % 1))])
                  [HiExprValue (HiValueFunction HiFunAdd)])
        `shouldBe` Left HiErrorInvalidFunction

      
  describe "Pretty printer" $ do
    it "pretty prints lists" $ do
      render (HiValueList $ fromList [HiValueNumber (1 % 1),
                                      HiValueNumber (2 % 1),
                                      HiValueNumber (3 % 1)])
        `shouldBe` "[1, 2, 3]"

      render (HiValueList $ fromList []) `shouldBe` "[]"

    it "pretty prints nested lists" $ do
      render (HiValueList $ fromList [HiValueList $ fromList [HiValueNumber (1 % 1),
                                                             HiValueNumber (2 % 1)],
                                      HiValueList $ fromList [HiValueNumber (3 % 1)]])
        `shouldBe` "[[1, 2], [3]]"