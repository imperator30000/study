import Test.Hspec (hspec, describe, it, shouldBe, shouldThrow, anyException)
import HW5.Parser (parse)
import HW5.Base (HiExpr, HiValue)
import TestTH (evalIdentity, render, fullEvaluate)
import qualified Data.Text as T
import HW5.Base (HiMonad(..))


main :: IO ()
main = hspec $ do
  describe "Full Evaluation Tests" $ do
  
    it "evaluates arithmetic expressions" $ do
      fullEvaluate "add(100, -15)" `shouldBe` Right "85"
      fullEvaluate "add(3, div(14, 100))" `shouldBe` Right "3.14"
      fullEvaluate "div(10, 3)" `shouldBe` Right "3 + 1 / 3"
      fullEvaluate "sub(mul(201, 11), 0.33)" `shouldBe` Right "2210.67"

    it "evaluates boolean expressions" $ do
      fullEvaluate "false" `shouldBe` Right "false"
      fullEvaluate "equals(add(2, 2), 4)" `shouldBe` Right "true"
      fullEvaluate "less-than(mul(999, 99), 10000)" `shouldBe` Right "false"
      fullEvaluate "if(greater-than(div(2, 5), div(3, 7)), 1, -1)" `shouldBe` Right "-1"
      fullEvaluate "and(less-than(0, 1), less-than(1, 0))" `shouldBe` Right "false"

    it "evaluates string operations" $ do
      fullEvaluate "to-upper(\"what a nice language\")(7, 11)" `shouldBe` Right "\"NICE\""
      fullEvaluate "\"Hello\" == \"World\"" `shouldBe` Right "false"
      fullEvaluate "length(\"Hello\" + \"World\")" `shouldBe` Right "10"
      fullEvaluate "length(\"hehe\" * 5) / 3" `shouldBe` Right "6 + 2 / 3"

    it "evaluates list operations" $ do
      fullEvaluate "list(1, 2, 3, 4, 5)" `shouldBe` Right "[1, 2, 3, 4, 5]"
      fullEvaluate "fold(add, [2, 5] * 3)" `shouldBe` Right "21"
      fullEvaluate "fold(mul, range(1, 10))" `shouldBe` Right "3628800"
      fullEvaluate "[0, true, false, \"hello\", \"world\"](2, 4)" `shouldBe` Right "[false, \"hello\"]"
      fullEvaluate "reverse(range(0.5, 27/8))" `shouldBe` Right "[3.5, 2.5, 1.5, 0.5]"

    it "evaluates bytes and serialisation" $ do
      fullEvaluate "pack-bytes(range(30, 40))" `shouldBe` Right "[# 1e 1f 20 21 22 23 24 25 26 27 28 #]"
      fullEvaluate "decode-utf8([# 68 69 #] * 5)" `shouldBe` Right "\"hihihihihi\""

    it "evaluates file operations" $ do
      fullEvaluate "mkdir(\"tmp\")" `shouldBe` Right "mkdir(\"tmp\")"

    it "evaluates date and time" $ do
      fullEvaluate "now" `shouldBe` Right "now"
      
      fullEvaluate "parse-time(\"2021-12-15 00:00:00 UTC\") + 1000"
        `shouldBe` Right "\"2021-12-15 00:16:40 UTC\""

    it "evaluates random numbers" $ do
      fullEvaluate "rand(0, 10)" `shouldBe` Right "rand(0, 10)"

    it "evaluates lazy evaluation" $ do
      fullEvaluate "if(2 == 2, 1, 0/1)" `shouldBe` Right "1"

    it "evaluates dictionaries" $ do
      fullEvaluate "count(\"Hello World\").o" `shouldBe` Right "2"
      fullEvaluate "fold(add, values(count(\"Hello, World!\")))" `shouldBe` Right "13"