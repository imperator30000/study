import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply))
import HW5.Base (HiValue(HiValueNumber, HiValueFunction))
import HW5.Base (HiFun(HiFunDiv, HiFunMul, HiFunAdd, HiFunSub))
import HW5.Base (HiError(HiErrorInvalidArgument, HiErrorInvalidFunction, HiErrorArityMismatch, HiErrorDivideByZero))
import Test.Hspec (hspec, describe, it, shouldBe)
import Data.Ratio ((%))
import TestTH (evalIdentity, render)
  


main :: IO ()
main = hspec $ do

  describe "Parser" $ do
    it "parses functions without arguments" $ do
      parse "add" `shouldBe` Right (HiExprValue (HiValueFunction HiFunAdd))
      parse "sub" `shouldBe` Right (HiExprValue (HiValueFunction HiFunSub))
      parse "mul" `shouldBe` Right (HiExprValue (HiValueFunction HiFunMul))
      parse "div" `shouldBe` Right (HiExprValue (HiValueFunction HiFunDiv))
      parse "add    " `shouldBe` Right (HiExprValue (HiValueFunction HiFunAdd))
      parse "   sub" `shouldBe` Right (HiExprValue (HiValueFunction HiFunSub))

    it "parses functions with arguments" $ do
      parse "add(1, 2)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
              [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])
      parse "sub(10, -5)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunSub)) 
              [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (-5 % 1))])

    it "parses functions with extra spaces" $ do
      parse "add  (  3 ,   5 )" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
              [HiExprValue (HiValueNumber (3 % 1)), HiExprValue (HiValueNumber (5 % 1))])
      parse "mul  (  2.5 , -1.25 )" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunMul)) 
              [HiExprValue (HiValueNumber (5 % 2)), HiExprValue (HiValueNumber (-125 % 100))])

    it "parses numbers in various formats" $ do
      parse "100" `shouldBe` Right (HiExprValue (HiValueNumber (100 % 1)))
      parse "-3.14" `shouldBe` Right (HiExprValue (HiValueNumber (-314 % 100)))
      parse "1.25e2" `shouldBe` Right (HiExprValue (HiValueNumber (125 % 1)))
      parse "-1.25e2" `shouldBe` Right (HiExprValue (HiValueNumber (-125 % 1)))

    it "parses nested functions" $ do
      parse "add(1, mul(2, 3))" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
              [HiExprValue (HiValueNumber (1 % 1)), 
               HiExprApply (HiExprValue (HiValueFunction HiFunMul)) 
                 [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))]])
      parse "mul(add(2, 3), sub(10, 5))" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunMul))
              [HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
               [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))],
               HiExprApply (HiExprValue (HiValueFunction HiFunSub)) 
               [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (5 % 1))]])

    it "parses functions with invalid arguments" $ do
      parse "add(1, 2, mul)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
              [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueFunction HiFunMul)])
      parse "div(1, add)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunDiv)) 
              [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueFunction HiFunAdd)])

    it "parses garbage cases" $ do
      parse "add(1, 2)(3, 4)" `shouldBe`
        Right (HiExprApply 
                (HiExprApply
                  (HiExprValue (HiValueFunction HiFunAdd)) 
                  [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])
                [HiExprValue (HiValueNumber (3 % 1)), HiExprValue (HiValueNumber (4 % 1))])
      parse "add(1, 2, 3, 4)" `shouldBe`
        Right (HiExprApply 
                (HiExprValue (HiValueFunction HiFunAdd)) 
                [HiExprValue (HiValueNumber (1 % 1)),
                  HiExprValue (HiValueNumber (2 % 1)),
                  HiExprValue (HiValueNumber (3 % 1)),
                  HiExprValue (HiValueNumber (4 % 1))])

  describe "Evaluator" $ do
    it "evaluates functions without arguments" $ do
      evalIdentity (HiExprValue (HiValueFunction HiFunAdd)) `shouldBe`
        Right (HiValueFunction HiFunAdd)

    it "evaluates functions with arguments" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
                    [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])
        `shouldBe`
        Right (HiValueNumber (3 % 1))
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunMul)) 
                    [HiExprValue (HiValueNumber (4 % 1)), HiExprValue (HiValueNumber (5 % 1))])
        `shouldBe`
        Right (HiValueNumber (20 % 1))

    it "evaluates simple functions" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
                    [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])
        `shouldBe`
        Right (HiValueNumber (3 % 1))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunMul)) 
                    [HiExprValue (HiValueNumber (4 % 1)), HiExprValue (HiValueNumber (5 % 1))])
        `shouldBe`
        Right (HiValueNumber (20 % 1))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunSub)) 
                    [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (7 % 1))])
        `shouldBe`
        Right (HiValueNumber (3 % 1))

    it "evaluates nested functions" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
                    [HiExprValue (HiValueNumber (1 % 1)), 
                     HiExprApply (HiExprValue (HiValueFunction HiFunMul)) 
                      [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))]])
        `shouldBe`
        Right (HiValueNumber (7 % 1))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunDiv)) 
                    [HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
                      [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (20 % 1))],
                     HiExprValue (HiValueNumber (5 % 1))])
        `shouldBe`
        Right (HiValueNumber (6 % 1))

    it "handles errors in functions" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunDiv)) 
                    [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (0 % 1))])
        `shouldBe`
        Left HiErrorDivideByZero

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
                    [HiExprValue (HiValueNumber (1 % 1))])
        `shouldBe`
        Left HiErrorArityMismatch

      evalIdentity (HiExprApply (HiExprValue (HiValueNumber (3 % 1))) 
                    [HiExprValue (HiValueNumber (1 % 1))])
        `shouldBe`
        Left HiErrorInvalidFunction

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd)) 
                    [HiExprValue (HiValueFunction HiFunMul), HiExprValue (HiValueNumber (2 % 1))])
        `shouldBe`
        Left HiErrorInvalidArgument

  describe "Pretty printer" $ do
    it "pretty prints functions" $ do
      render (HiValueFunction HiFunAdd) `shouldBe` "add"
      render (HiValueFunction HiFunSub) `shouldBe` "sub"
      render (HiValueFunction HiFunMul) `shouldBe` "mul"
      render (HiValueFunction HiFunDiv) `shouldBe` "div"

    it "pretty prints numbers in different formats" $ do
      render (HiValueNumber (5 % 1)) `shouldBe` "5"
      render (HiValueNumber (-3 % 1)) `shouldBe` "-3"
      render (HiValueNumber (8 % 3)) `shouldBe` "2 + 2 / 3"
      render (HiValueNumber (-23 % 7)) `shouldBe` "-3 - 2 / 7"
      render (HiValueNumber (9 % 10)) `shouldBe` "0.9"
      render (HiValueNumber (-89 % 10)) `shouldBe` "-8.9"
      render (HiValueNumber (7 % 1000000000)) `shouldBe` "7.0e-9"
      render (HiValueNumber (-9 % 1000000000)) `shouldBe` "-9.0e-9"
