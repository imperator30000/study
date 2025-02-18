{-# LANGUAGE LambdaCase #-}
import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply, HiExprRun),
                 HiValue(HiValueAction, HiValueNumber, HiValueFunction),
                 HiFun(HiFunRand),
                 HiAction(HiActionRand),
                 HiError(HiErrorInvalidArgument),
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
    it "parses rand functions" $ do
      parse "rand(0, 10)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunRand))
              [HiExprValue (HiValueNumber 0), HiExprValue (HiValueNumber 10)])

      parse "rand" `shouldBe`
        Right (HiExprValue (HiValueFunction HiFunRand))

  describe "Evaluator" $ do
    it "evaluates rand function without executing (returns HiValueAction)" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunRand))
                   [HiExprValue (HiValueNumber 0), HiExprValue (HiValueNumber 100)])
        `shouldBe` Right (HiValueAction (HiActionRand 0 100))

  describe "HIO Monad" $ do
    let runWithPerms perms action =
          runHIO action (Set.fromList perms)

    context "with AllowTime permission for randomness" $ do
      it "generates random numbers uniformly in the given range" $ do
        result <- runWithPerms [AllowTime] (runAction (HiActionRand 0 5))
        result `shouldSatisfy` (\case
                                  HiValueNumber x -> x >= 0 && x <= 5
                                  _               -> False)

  describe "Pretty printer" $ do
    it "pretty prints rand function" $ do
      render (HiValueFunction HiFunRand) `shouldBe` "rand"
    it "pretty prints rand actions" $ do
      render (HiValueAction (HiActionRand 0 5)) `shouldBe` "rand(0, 5)"