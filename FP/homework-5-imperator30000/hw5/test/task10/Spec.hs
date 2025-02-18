{-# LANGUAGE LambdaCase #-}
import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply, HiExprRun),
                 HiValue(HiValueAction, HiValueBool, HiValueNull, HiValueFunction, HiValueString, HiValueNumber),
                 HiFun(HiFunEcho, HiFunAnd, HiFunOr, HiFunDiv, HiFunAdd, HiFunIf),
                 HiAction(HiActionEcho),
                 HiError(HiErrorArityMismatch, HiErrorDivideByZero),
                 HiMonad(..))
import HW5.Action (HIO(..), HiPermission(..), PermissionException(..))
import HW5.Evaluator (eval)
import HW5.Pretty (prettyValue)
import Control.Monad.Identity (Identity, runIdentity)
import qualified Data.Text as Text
import qualified Data.Set as Set
import Test.Hspec (hspec, describe, it, shouldBe, shouldThrow, shouldSatisfy, context)
import Control.Exception (evaluate)
import Prettyprinter.Render.String (renderString)
import Prettyprinter (layoutPretty, defaultLayoutOptions)
import TestTH (evalIdentity, render)

main :: IO ()
main = hspec $ do
  describe "Parser" $ do
    it "parses echo functions" $ do
      parse "echo(\"Hello\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunEcho))
              [HiExprValue (HiValueString (Text.pack "Hello"))])

      parse "echo" `shouldBe`
        Right (HiExprValue (HiValueFunction HiFunEcho))

    it "parses and/or with lazy semantics" $ do
      parse "true || echo(\"Unused\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunOr))
              [HiExprValue (HiValueBool True), 
               HiExprApply (HiExprValue (HiValueFunction HiFunEcho)) 
                 [HiExprValue (HiValueString (Text.pack "Unused"))]])

      parse "false && echo(\"Unused\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
              [HiExprValue (HiValueBool False), 
               HiExprApply (HiExprValue (HiValueFunction HiFunEcho)) 
                 [HiExprValue (HiValueString (Text.pack "Unused"))]])

  describe "Evaluator" $ do
    it "does not evaluate false branch of if when condition is true" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                   [HiExprValue (HiValueBool True),
                    HiExprValue (HiValueNumber 12),
                    HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                      [HiExprValue (HiValueNumber 1), HiExprValue (HiValueNumber 0)]])
        `shouldBe` Right (HiValueNumber 12)

    it "does not evaluate true branch of if when condition is false" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunIf))
                   [HiExprValue (HiValueBool False),
                    HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                      [HiExprValue (HiValueNumber 1), HiExprValue (HiValueNumber 0)],
                    HiExprValue (HiValueNumber 12)])
        `shouldBe` Right (HiValueNumber 12)

    it "does not evaluate second operand of || when first is true" $ do
      evalIdentity (
                    HiExprApply (HiExprValue (HiValueFunction HiFunOr))
                      [HiExprValue (HiValueBool True),
                       HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                         [HiExprValue (HiValueNumber 1), HiExprValue (HiValueNumber 0)]])
        `shouldBe` Right (HiValueBool True)

    it "does not evaluate second operand of && when first is false" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
                      [HiExprValue (HiValueBool False),
                       HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                         [HiExprValue (HiValueNumber 1), HiExprValue (HiValueNumber 0)]])
        `shouldBe` Right (HiValueBool False)

    it "does evaluate second operand of || when first is false" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunOr))
                   [HiExprValue (HiValueBool False),
                    HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                      [HiExprValue (HiValueNumber 1), HiExprValue (HiValueNumber 0)]])
        `shouldBe` Left HiErrorDivideByZero

    it "does evaluate second operand of && when first is true" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAnd))
                   [HiExprValue (HiValueBool True),
                    HiExprApply (HiExprValue (HiValueFunction HiFunDiv))
                      [HiExprValue (HiValueNumber 1), HiExprValue (HiValueNumber 0)]])
        `shouldBe` Left HiErrorDivideByZero

  describe "HIO Monad" $ do
    let runWithPerms perms action =
          runHIO action (Set.fromList perms)

    context "with AllowWrite permission" $ do
      it "executes echo correctly" $ do
        result <- runWithPerms [AllowWrite] (runAction (HiActionEcho (Text.pack "Hello")))
        result `shouldBe` HiValueNull

    context "permissions handling" $ do
      it "throws PermissionException for echo when AllowWrite is missing" $ do
        runWithPerms [] (runAction (HiActionEcho (Text.pack "Hello")))
          `shouldThrow` (\case
                          PermissionRequired AllowWrite -> True
                          _ -> False)

  describe "Pretty printer" $ do
    it "pretty prints echo function" $ do
      render (HiValueFunction HiFunEcho) `shouldBe` "echo"

    it "pretty prints echo action" $ do
      render (HiValueAction (HiActionEcho (Text.pack "Hello"))) `shouldBe` "echo(\"Hello\")"
