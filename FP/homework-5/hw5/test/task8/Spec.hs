import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply, HiExprRun))
import HW5.Base (HiValue(HiValueTime, HiValueAction, HiValueNull, HiValueString, HiValueNumber, HiValueFunction))
import HW5.Base (HiFun(HiFunParseTime, HiFunAdd, HiFunSub), HiAction(HiActionNow))
import HW5.Base (HiError(HiErrorInvalidArgument))
import HW5.Base (HiMonad(..))
import HW5.Action (HIO(..), HiPermission(..), PermissionException(..))
import qualified Data.Text as Text
import qualified Data.ByteString as BS
import qualified Data.Set as Set
import Data.Time.Clock (UTCTime, getCurrentTime, addUTCTime, diffUTCTime)
import Data.Ratio ((%))
import Test.Hspec (hspec, describe, it, shouldBe, shouldThrow, shouldSatisfy)
import Control.Exception (evaluate)
import Control.Monad.Identity (Identity, runIdentity)
import HW5.Evaluator (eval)
import TestTH (evalIdentity, render)

main :: IO ()
main = hspec $ do
  describe "Parser" $ do
    it "parses time-related functions and actions" $ do
      parse "parse-time(\"2021-12-15 00:00:00 UTC\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunParseTime))
              [HiExprValue (HiValueString (Text.pack "2021-12-15 00:00:00 UTC"))])

      parse "now!" `shouldBe`
        Right (HiExprRun (HiExprValue (HiValueAction HiActionNow)))

  describe "Evaluator" $ do
    it "evaluates parse-time" $ do
      let timeStr = "2021-12-15 00:00:00 UTC"
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunParseTime))
                   [HiExprValue (HiValueString (Text.pack timeStr))])
        `shouldBe` Right (HiValueTime (read timeStr))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunParseTime))
                   [HiExprValue (HiValueString (Text.pack "invalid time"))])
        `shouldBe` Left HiErrorInvalidArgument

    it "evaluates arithmetic operations on times" $ do
      let timeStr1 = "2021-12-15 00:00:00 UTC"
      let timeStr2 = "2021-12-15 00:16:40 UTC"
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunAdd))
                   [HiExprApply (HiExprValue (HiValueFunction HiFunParseTime))
                                [HiExprValue (HiValueString (Text.pack timeStr1))],
                    HiExprValue (HiValueNumber 1000)])
        `shouldBe` Right (HiValueTime (read timeStr2))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunSub))
                   [HiExprApply (HiExprValue (HiValueFunction HiFunParseTime))
                                [HiExprValue (HiValueString (Text.pack timeStr2))],
                    HiExprApply (HiExprValue (HiValueFunction HiFunParseTime))
                                [HiExprValue (HiValueString (Text.pack timeStr1))]])
        `shouldBe` Right (HiValueNumber 1000)

  describe "HIO Monad" $ do
    let runWithPerms perms action =
          runHIO action (Set.fromList perms)

    it "returns current system time when AllowTime is granted" $ do
      result <- runWithPerms [AllowTime] (runAction HiActionNow)
      currentTime <- getCurrentTime
      case result of
        HiValueTime returnedTime -> diffUTCTime currentTime returnedTime `shouldSatisfy` (< 1)
        _ -> error "Expected HiValueTime"

    it "throws PermissionException when AllowTime is denied" $ do
      runWithPerms [] (runAction HiActionNow)
        `shouldThrow` (\e -> case e of
                               PermissionRequired AllowTime -> True
                               _ -> False)
  describe "Pretty printer" $ do
    it "pretty prints times" $ do
      let time = read "2021-12-15 00:00:00 UTC" :: UTCTime
      render (HiValueTime time) `shouldBe` "\"2021-12-15 00:00:00 UTC\""
    it "pretty prints now" $ do
      render (HiValueAction HiActionNow) `shouldBe` "now"