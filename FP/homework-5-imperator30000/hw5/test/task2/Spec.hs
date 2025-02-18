import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply))
import HW5.Base (HiValue(HiValueNumber, HiValueFunction, HiValueBool))
import HW5.Base (HiFun(
                        HiFunAdd, 
                        HiFunSub, 
                        HiFunIf, 
                        HiFunNot, 
                        HiFunOr, 
                        HiFunAnd, 
                        HiFunLessThan,
                        HiFunGreaterThan,
                        HiFunNotLessThan,
                        HiFunNotGreaterThan,
                        HiFunEquals,
                        HiFunNotEquals
                        ))
import HW5.Base (HiError(HiErrorInvalidArgument, HiErrorInvalidFunction, HiErrorArityMismatch))
import Test.Hspec (hspec, describe, it, shouldBe)
import Data.Ratio ((%))
import TestTH (evalIdentity, render)

  
main :: IO()
main = hspec $ do
  describe "Parser" $ do
    it "parses values" $ do
      parse "true" `shouldBe` Right (HiExprValue (HiValueBool True))
      parse "false" `shouldBe` Right (HiExprValue (HiValueBool False))

    it "parses functions without arguments" $ do
      parse "not" `shouldBe` Right (HiExprValue (HiValueFunction HiFunNot))
      parse "and" `shouldBe` Right (HiExprValue (HiValueFunction HiFunAnd))
      parse "or" `shouldBe` Right (HiExprValue (HiValueFunction HiFunOr))
      parse "less-than" `shouldBe` Right (HiExprValue (HiValueFunction HiFunLessThan))
      parse "greater-than" `shouldBe` Right (HiExprValue (HiValueFunction HiFunGreaterThan))
      parse "not-less-than" `shouldBe` Right (HiExprValue (HiValueFunction HiFunNotLessThan))
      parse "not-greater-than" `shouldBe` Right (HiExprValue (HiValueFunction HiFunNotGreaterThan))
      parse "equals" `shouldBe` Right (HiExprValue (HiValueFunction HiFunEquals))
      parse "not-equals" `shouldBe` Right (HiExprValue (HiValueFunction HiFunNotEquals))
      parse "if" `shouldBe` Right (HiExprValue (HiValueFunction HiFunIf))

    it "parses functions with arguments" $ do
      parse "and(true, false)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
              [HiExprValue (HiValueBool True), HiExprValue (HiValueBool False)])

      parse "or(true, false)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunOr))
              [HiExprValue (HiValueBool True), HiExprValue (HiValueBool False)])

      parse "less-than(1, 2)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunLessThan))
              [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "greater-than(3, 4)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunGreaterThan))
              [HiExprValue (HiValueNumber (3 % 1)), HiExprValue (HiValueNumber (4 % 1))])

      parse "not-less-than(5, 6)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunNotLessThan))
              [HiExprValue (HiValueNumber (5 % 1)), HiExprValue (HiValueNumber (6 % 1))])

      parse "not-greater-than(7, 8)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunNotGreaterThan))
              [HiExprValue (HiValueNumber (7 % 1)), HiExprValue (HiValueNumber (8 % 1))])
              
      parse "equals(1, 1)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunEquals))
              [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (1 % 1))])

      parse "not-equals(10, 20)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunNotEquals))
              [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (20 % 1))])
    
      parse "if(true, 10, 20)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
              [HiExprValue (HiValueBool True), HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (20 % 1))])

  describe "Evaluator" $ do

    it "evaluates values" $ do
      evalIdentity (HiExprValue (HiValueBool True)) `shouldBe` Right (HiValueBool True)
      evalIdentity (HiExprValue (HiValueBool False)) `shouldBe` Right (HiValueBool False)

    it "evaluates functions without arguments" $ do
      evalIdentity (HiExprValue (HiValueFunction HiFunAnd)) `shouldBe`
        Right (HiValueFunction HiFunAnd)  

      evalIdentity (HiExprValue (HiValueFunction HiFunOr)) `shouldBe`
        Right (HiValueFunction HiFunOr)
      
      evalIdentity (HiExprValue (HiValueFunction HiFunNot)) `shouldBe`
        Right (HiValueFunction HiFunNot)  

      evalIdentity (HiExprValue (HiValueFunction HiFunLessThan)) `shouldBe`
        Right (HiValueFunction HiFunLessThan)

      evalIdentity (HiExprValue (HiValueFunction HiFunGreaterThan)) `shouldBe`
        Right (HiValueFunction HiFunGreaterThan)

      evalIdentity (HiExprValue (HiValueFunction HiFunNotLessThan)) `shouldBe`
        Right (HiValueFunction HiFunNotLessThan)

      evalIdentity (HiExprValue (HiValueFunction HiFunNotGreaterThan)) `shouldBe`
        Right (HiValueFunction HiFunNotGreaterThan)

      evalIdentity (HiExprValue (HiValueFunction HiFunEquals)) `shouldBe`
        Right (HiValueFunction HiFunEquals)

      evalIdentity (HiExprValue (HiValueFunction HiFunNotEquals)) `shouldBe`
        Right (HiValueFunction HiFunNotEquals)  

    it "evaluates functions with arguments" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunNot))
                    [HiExprValue (HiValueBool True)]) `shouldBe` Right (HiValueBool False)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
                    [HiExprValue (HiValueBool True), HiExprValue (HiValueBool False)])
        `shouldBe` Right (HiValueBool False)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunOr))
                    [HiExprValue (HiValueBool True), HiExprValue (HiValueBool False)])
        `shouldBe` Right (HiValueBool True)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                    [HiExprValue (HiValueBool True), HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (20 % 1))])
        `shouldBe` Right (HiValueNumber (10 % 1))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                    [HiExprValue (HiValueBool False), HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (20 % 1))])
        `shouldBe` Right (HiValueNumber (20 % 1))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunLessThan))
                    [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])
        `shouldBe` Right (HiValueBool True)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunGreaterThan))
                    [HiExprValue (HiValueNumber (3 % 1)), HiExprValue (HiValueNumber (2 % 1))])
        `shouldBe` Right (HiValueBool True)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunNotLessThan))
                    [HiExprValue (HiValueNumber (4 % 1)), HiExprValue (HiValueNumber (4 % 1))])
        `shouldBe` Right (HiValueBool True)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunNotGreaterThan))
                    [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))])
        `shouldBe` Right (HiValueBool True)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunEquals))
                    [HiExprValue (HiValueNumber (5 % 1)), HiExprValue (HiValueNumber (5 % 1))])
        `shouldBe` Right (HiValueBool True)

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunNotEquals))
                    [HiExprValue (HiValueNumber (6 % 1)), HiExprValue (HiValueNumber (7 % 1))])
        `shouldBe` Right (HiValueBool True)

    it "handles errors" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
                    [HiExprValue (HiValueBool True)]) `shouldBe` Left HiErrorArityMismatch

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                    [HiExprValue (HiValueBool True), HiExprValue (HiValueNumber (10 % 1))])
        `shouldBe` Left HiErrorArityMismatch

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunNot))
                    [HiExprValue (HiValueNumber (10 % 1))])
        `shouldBe` Left HiErrorInvalidArgument

      evalIdentity (HiExprApply (HiExprValue (HiValueBool True)) 
                    [HiExprValue (HiValueNumber (1 % 1))])
        `shouldBe`
        Left HiErrorInvalidFunction
    
    it "evaluates if with functions and args" $ do
      evalIdentity (HiExprApply
                    (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                                    [HiExprValue (HiValueBool True),
                                    HiExprValue (HiValueFunction HiFunAdd),
                                    HiExprValue (HiValueFunction HiFunSub)])
                    [HiExprValue (HiValueNumber (5 % 1)), HiExprValue (HiValueNumber (8 % 1))])
        `shouldBe` Right (HiValueNumber (13 % 1))
      evalIdentity (HiExprApply
                    (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                                    [HiExprValue (HiValueBool False),
                                    HiExprValue (HiValueFunction HiFunAdd),
                                    HiExprValue (HiValueFunction HiFunSub)])
                    [HiExprValue (HiValueNumber (5 % 1)), HiExprValue (HiValueNumber (8 % 1))])
        `shouldBe` Right (HiValueNumber (-3 % 1))


    it "evaluates nested function" $ do
      evalIdentity (HiExprApply
                      (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                                   [HiExprValue (HiValueBool True), HiExprValue (HiValueFunction HiFunAdd), HiExprValue (HiValueFunction HiFunSub)])
                      [HiExprValue (HiValueNumber (19 % 1)), HiExprValue (HiValueNumber (4 % 1))])
        `shouldBe` Right (HiValueNumber (23 % 1))
    
      evalIdentity (HiExprApply
                      (HiExprValue (HiValueFunction HiFunAnd))
                      [HiExprApply (HiExprValue (HiValueFunction HiFunLessThan))
                                   [HiExprValue (HiValueNumber (1 % 1)), HiExprValue (HiValueNumber (2 % 1))],
                       HiExprApply (HiExprValue (HiValueFunction HiFunGreaterThan))
                                   [HiExprValue (HiValueNumber (3 % 1)), HiExprValue (HiValueNumber (4 % 1))]])
        `shouldBe` Right (HiValueBool False)

      evalIdentity (HiExprApply
                      (HiExprValue (HiValueFunction HiFunIf))
                      [HiExprApply (HiExprValue (HiValueFunction HiFunEquals))
                                   [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (10 % 1))],
                       HiExprApply (HiExprValue (HiValueFunction HiFunNotEquals))
                                   [HiExprValue (HiValueNumber (5 % 1)), HiExprValue (HiValueNumber (5 % 1))],
                       HiExprApply (HiExprValue (HiValueFunction HiFunNot))
                                   [HiExprValue (HiValueBool True)]])
        `shouldBe` Right (HiValueBool False)
  describe "Pretty printer" $ do
    it "pretty prints boolean values" $ do
      render (HiValueBool True) `shouldBe` "true"
      render (HiValueBool False) `shouldBe` "false"

    it "pretty prints functions" $ do
      render (HiValueFunction HiFunAnd) `shouldBe` "and"
      render (HiValueFunction HiFunOr) `shouldBe` "or"
      render (HiValueFunction HiFunNot) `shouldBe` "not"
      render (HiValueFunction HiFunLessThan) `shouldBe` "less-than"
      render (HiValueFunction HiFunGreaterThan) `shouldBe` "greater-than"
      render (HiValueFunction HiFunNotLessThan) `shouldBe` "not-less-than"
      render (HiValueFunction HiFunNotGreaterThan) `shouldBe` "not-greater-than"
      render (HiValueFunction HiFunEquals) `shouldBe` "equals"
      render (HiValueFunction HiFunNotEquals) `shouldBe` "not-equals"
      render (HiValueFunction HiFunIf) `shouldBe` "if"