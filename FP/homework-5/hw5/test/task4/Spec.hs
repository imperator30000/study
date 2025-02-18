import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply))
import HW5.Base (HiValue(HiValueNumber, HiValueFunction, HiValueNull, HiValueString))
import HW5.Base (HiFun(
                        HiFunAdd,
                        HiFunMul,
                        HiFunDiv,
                        HiFunLength,
                        HiFunToUpper,
                        HiFunToLower,
                        HiFunReverse,
                        HiFunTrim
                        ))
import Test.Hspec (hspec, describe, it, shouldBe)
import HW5.Base (HiError(HiErrorInvalidFunction))
import TestTH (evalIdentity, render)
import qualified Data.Text as Text
import Data.Ratio ((%))


main :: IO()
main = hspec $ do
  describe "Parser" $ do
    it "parses values" $ do
        parse "\"hello\"" `shouldBe` Right (HiExprValue (HiValueString (Text.pack "hello")))
        parse "\"Header\\nFooter\"" `shouldBe` Right (HiExprValue (HiValueString (Text.pack "Header\nFooter")))
        parse "\"42\"" `shouldBe` Right (HiExprValue (HiValueString (Text.pack "42")))
        parse "\"Hello \\\"World\\\"\"" `shouldBe` Right (HiExprValue (HiValueString (Text.pack "Hello \"World\"")))
        parse "null" `shouldBe` Right (HiExprValue HiValueNull)
    
    it "parses functions without arguments" $ do
        parse "length" `shouldBe` Right (HiExprValue (HiValueFunction HiFunLength))
        parse "to-upper" `shouldBe` Right (HiExprValue (HiValueFunction HiFunToUpper))
        parse "to-lower" `shouldBe` Right (HiExprValue (HiValueFunction HiFunToLower))
        parse "reverse" `shouldBe` Right (HiExprValue (HiValueFunction HiFunReverse))
        parse "trim" `shouldBe` Right (HiExprValue (HiValueFunction HiFunTrim))
        
    it "parses functions with arguments" $ do
        parse "length" `shouldBe` Right (HiExprValue (HiValueFunction HiFunLength))
        parse "to-upper" `shouldBe` Right (HiExprValue (HiValueFunction HiFunToUpper))
        parse "to-lower" `shouldBe` Right (HiExprValue (HiValueFunction HiFunToLower))
        parse "reverse" `shouldBe` Right (HiExprValue (HiValueFunction HiFunReverse))
        parse "trim" `shouldBe` Right (HiExprValue (HiValueFunction HiFunTrim))
        
    it "parses string operations" $ do
        parse "\"Hello\" + \"World\"" `shouldBe`
            Right (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                [HiExprValue (HiValueString (Text.pack "Hello")), HiExprValue (HiValueString (Text.pack "World"))])

        parse "\"Cat\" * 3" `shouldBe`
            Right (HiExprApply (HiExprValue (HiValueFunction HiFunMul))
                [HiExprValue (HiValueString (Text.pack "Cat")), HiExprValue (HiValueNumber (3 % 1))])

        parse "\"/home\" / \"user\"" `shouldBe`
            Right (HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                [HiExprValue (HiValueString (Text.pack "/home")), HiExprValue (HiValueString (Text.pack "user"))])

    it "parses string indexing and slicing" $ do
        parse "\"Hello\"(0)" `shouldBe`
            Right (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello"))) [HiExprValue (HiValueNumber (0 % 1))])

        parse "\"Hello\"(0, 3)" `shouldBe`
            Right (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello")))
                [HiExprValue (HiValueNumber (0 % 1)), HiExprValue (HiValueNumber (3 % 1))])

  describe "Evaluator" $ do
    it "evaluates string concatenation" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                     [HiExprValue (HiValueString (Text.pack "Hello")),
                      HiExprValue (HiValueString (Text.pack "World"))])
        `shouldBe` Right (HiValueString (Text.pack "HelloWorld"))

    it "evaluates string repetition" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunMul))
                     [HiExprValue (HiValueString (Text.pack "Cat")),
                      HiExprValue (HiValueNumber (3 % 1))])
        `shouldBe` Right (HiValueString (Text.pack "CatCatCat"))

    it "evaluates string division (path concatenation)" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                     [HiExprValue (HiValueString (Text.pack "/home")),
                      HiExprValue (HiValueString (Text.pack "user"))])
            `shouldBe` Right (HiValueString (Text.pack "/home/user"))

    it "evaluates string length" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunLength))
                     [HiExprValue (HiValueString (Text.pack "Hello"))])
            `shouldBe` Right (HiValueNumber (5 % 1))

    it "evaluates string transformations" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunToUpper))
                     [HiExprValue (HiValueString (Text.pack "Hello"))])
            `shouldBe` Right (HiValueString (Text.pack "HELLO"))

        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunToLower))
                     [HiExprValue (HiValueString (Text.pack "HELLO"))])
            `shouldBe` Right (HiValueString (Text.pack "hello"))

        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunReverse))
                     [HiExprValue (HiValueString (Text.pack "desserts"))])
            `shouldBe` Right (HiValueString (Text.pack "stressed"))

        evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunTrim))
                     [HiExprValue (HiValueString (Text.pack "  Hello World  "))])
            `shouldBe` Right (HiValueString (Text.pack "Hello World"))

    it "evaluates string indexing" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello")))
                     [HiExprValue (HiValueNumber (0 % 1))])
            `shouldBe` Right (HiValueString (Text.pack "H"))

        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello")))
                     [HiExprValue (HiValueNumber (4 % 1))])
            `shouldBe` Right (HiValueString (Text.pack "o"))

        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack"Hello")))
                     [HiExprValue (HiValueNumber (99 % 1))])
            `shouldBe` Right HiValueNull

    it "evaluates string slicing" $ do
        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello")))
                     [HiExprValue (HiValueNumber (0 % 1)),
                      HiExprValue (HiValueNumber (4 % 1))])
            `shouldBe` Right (HiValueString (Text.pack "Hell"))

        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello, World")))
                     [HiExprValue (HiValueNumber (2 % 1)),
                      HiExprValue (HiValueNumber (-4 % 1))])
            `shouldBe` Right (HiValueString (Text.pack "llo, W"))

        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello, World")))
                     [HiExprValue (HiValueNumber (-5 % 1)),
                      HiExprValue HiValueNull])
            `shouldBe` Right (HiValueString (Text.pack "World"))

        evalIdentity (HiExprApply (HiExprValue (HiValueString (Text.pack "Hello")))
                     [HiExprValue HiValueNull,
                      HiExprValue HiValueNull])
            `shouldBe` Left HiErrorInvalidFunction

  describe "Pretty printer" $ do
    it "pretty prints strings" $ do
      render (HiValueString (Text.pack "Hello, World!")) `shouldBe` "\"Hello, World!\""
      render (HiValueString (Text.pack "  Hello, World!   ")) `shouldBe` "\"  Hello, World!   \""
      render (HiValueString (Text.pack "1/10")) `shouldBe` "\"1/10\""
      render (HiValueString (Text.pack "null")) `shouldBe` "\"null\""

    it "pretty prints null" $ do
      render HiValueNull `shouldBe` "null"

    it "pretty prints functions" $ do
      render (HiValueFunction HiFunLength) `shouldBe` "length"
      render (HiValueFunction HiFunToUpper) `shouldBe` "to-upper"
      render (HiValueFunction HiFunToLower) `shouldBe` "to-lower"
      render (HiValueFunction HiFunTrim) `shouldBe` "trim"
      render (HiValueFunction HiFunReverse) `shouldBe` "reverse"
