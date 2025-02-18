import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply))
import HW5.Base (HiValue(HiValueNumber, HiValueFunction, HiValueBool))
import HW5.Base (HiFun(
                        HiFunMul,
                        HiFunDiv,
                        HiFunAdd, 
                        HiFunSub, 
                        HiFunOr, 
                        HiFunAnd, 
                        HiFunLessThan,
                        HiFunGreaterThan,
                        HiFunNotLessThan,
                        HiFunNotGreaterThan,
                        HiFunEquals,
                        HiFunNotEquals
                        ))
import Test.Hspec (hspec, describe, it, shouldBe)
import Data.Ratio ((%))



main :: IO()
main = hspec $ do
  describe "Parser" $ do
    it "parses simple expressions" $ do
      parse "2 + 2" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "2 - 2" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunSub))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "10 / 2" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
              [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "10 * 2" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunMul))
              [HiExprValue (HiValueNumber (10 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "2 < 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunLessThan))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))])

      parse "2 > 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunGreaterThan))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))])

      parse "2 == 2" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunEquals))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "2 /= 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunNotEquals))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))])

      parse "2 >= 2" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunNotLessThan))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))])

      parse "2 <= 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunNotGreaterThan))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))])

      parse "true && false" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
              [HiExprValue (HiValueBool True), HiExprValue (HiValueBool False)])

      parse "true || false" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunOr))
              [HiExprValue (HiValueBool True), HiExprValue (HiValueBool False)])

    it "parses complex expressions" $ do
      parse "2 + 2 * 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
              [HiExprValue (HiValueNumber (2 % 1)),
               HiExprApply (HiExprValue (HiValueFunction HiFunMul))
                           [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))]])

      parse "(2 + 2) * 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunMul))
              [HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                           [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))],
               HiExprValue (HiValueNumber (3 % 1))])

      parse "2 + 2 * 3 == (2 + 2) * 3" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunEquals))
              [HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                           [HiExprValue (HiValueNumber (2 % 1)),
                            HiExprApply (HiExprValue (HiValueFunction HiFunMul))
                                        [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (3 % 1))]],
               HiExprApply (HiExprValue (HiValueFunction HiFunMul))
                           [HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                                        [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))],
                            HiExprValue (HiValueNumber (3 % 1))]])
    
    it "parses expressions with spaces" $ do
      parse "    2      +2    " `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
              [HiExprValue (HiValueNumber (2 % 1)), HiExprValue (HiValueNumber (2 % 1))])

