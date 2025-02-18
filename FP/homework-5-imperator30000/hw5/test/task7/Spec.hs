import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply, HiExprRun),
                 HiValue(HiValueAction, HiValueNull, HiValueString, HiValueBytes, HiValueList, HiValueFunction),
                 HiAction(HiActionRead, HiActionWrite, HiActionMkDir, HiActionChDir, HiActionCwd),
                 HiFun(HiFunRead, HiFunWrite, HiFunMkDir, HiFunChDir),
                 HiError(HiErrorInvalidArgument, HiErrorArityMismatch), 
                 HiMonad(..))
import HW5.Action (HIO(..), HiPermission(..), PermissionException(..))
import HW5.Evaluator (eval)
import Control.Monad.Identity (Identity, runIdentity)
import qualified Data.ByteString as BS
import qualified Data.Text as Text
import qualified Data.Set as Set
import Data.Sequence (fromList)
import Data.Ratio ((%))
import Test.Hspec (hspec, describe, it, shouldBe, shouldThrow, context)
import System.Directory (getCurrentDirectory, setCurrentDirectory, createDirectory, doesDirectoryExist, listDirectory, removeFile, removeDirectory, removeDirectoryRecursive)
import Control.Exception (evaluate)
import TestTH (evalIdentity, render)

main :: IO ()
main = hspec $ do
  describe "Parser" $ do
    it "parses file I/O actions" $ do
      parse "read(\"file.txt\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunRead))
              [HiExprValue (HiValueString (Text.pack "file.txt"))])

      parse "write(\"file.txt\", \"content\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunWrite))
              [HiExprValue (HiValueString (Text.pack "file.txt")),
               HiExprValue (HiValueString (Text.pack "content"))])

      parse "mkdir(\"mydir\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunMkDir))
              [HiExprValue (HiValueString (Text.pack "mydir"))])

      parse "cd(\"mydir\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunChDir))
              [HiExprValue (HiValueString (Text.pack "mydir"))])

      parse "cwd!" `shouldBe`
        Right (HiExprRun (HiExprValue (HiValueAction HiActionCwd)))

      parse "read(\"file.txt\")!" `shouldBe`
        Right (HiExprRun (HiExprApply (HiExprValue (HiValueFunction HiFunRead))
              [HiExprValue (HiValueString (Text.pack "file.txt"))]))

  describe "Evaluator" $ do
    it "evaluates file actions without running them" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunRead))
                   [HiExprValue (HiValueString (Text.pack "file.txt"))])
        `shouldBe` Right (HiValueAction (HiActionRead "file.txt"))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunWrite))
                   [HiExprValue (HiValueString (Text.pack "file.txt")),
                    HiExprValue (HiValueString (Text.pack "content"))])
        `shouldBe` Right (HiValueAction (HiActionWrite "file.txt" (BS.pack [0x63, 0x6f, 0x6e, 0x74, 0x65, 0x6e, 0x74])))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunMkDir))
                   [HiExprValue (HiValueString (Text.pack "mydir"))])
        `shouldBe` Right (HiValueAction (HiActionMkDir "mydir"))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunChDir))
                   [HiExprValue (HiValueString (Text.pack "mydir"))])
        `shouldBe` Right (HiValueAction (HiActionChDir "mydir"))

  describe "HIO Monad" $ do
    let runWithPerms perms action =
          runHIO action (Set.fromList perms)

    context "with AllowRead permission" $ do
      it "allows reading the current directory" $ do
        result <- runWithPerms [AllowRead] (runAction HiActionCwd)
        cwd <- getCurrentDirectory
        result `shouldBe` HiValueString (Text.pack cwd)

      it "allows reading a file" $ do
        writeFile "testfile.txt" "Hello, World!"
        result <- runWithPerms [AllowRead] (runAction (HiActionRead "testfile.txt"))
        result `shouldBe` HiValueString (Text.pack "Hello, World!")
        removeFile "testfile.txt"

      it "returns directory listing" $ do
        createDirectory "testdir"
        writeFile "testdir/file.txt" "test content"
        result <- runWithPerms [AllowRead] (runAction (HiActionRead "testdir"))
        result `shouldBe` HiValueList (fromList [HiValueString (Text.pack "file.txt")])
        removeFile "testdir/file.txt"
        removeDirectoryRecursive "testdir"

    context "with AllowWrite permission" $ do
      it "allows creating a directory" $ do
        result <- runWithPerms [AllowWrite] (runAction (HiActionMkDir "newdir"))
        result `shouldBe` HiValueNull
        exists <- doesDirectoryExist "newdir"
        exists `shouldBe` True
        removeDirectory "newdir"

      it "allows writing to a file" $ do
        result <- runWithPerms [AllowWrite] (runAction (HiActionWrite "newfile.txt" (BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f])))
        result `shouldBe` HiValueNull
        content <- BS.readFile "newfile.txt"
        content `shouldBe` BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f]
        removeFile "newfile.txt"

    context "permissions handling" $ do
      it "throws PermissionException when AllowRead is missing" $ do
        runWithPerms [] (runAction HiActionCwd)
          `shouldThrow` (\e -> case e of
                             PermissionRequired AllowRead -> True
                             _ -> False)

        runWithPerms [] (runAction (HiActionRead "testfile.txt"))
          `shouldThrow` (\e -> case e of
                             PermissionRequired AllowRead -> True
                             _ -> False)

      it "throws PermissionException when AllowWrite is missing" $ do
        runWithPerms [] (runAction (HiActionWrite "newfile.txt" (BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f])))
          `shouldThrow` (\e -> case e of
                                    PermissionRequired AllowWrite -> True
                                    _ -> False)

        runWithPerms [] (runAction (HiActionMkDir "newdir"))
          `shouldThrow` (\e -> case e of
                                    PermissionRequired AllowWrite -> True
                                    _ -> False)
  describe "Pretty printer" $ do
    it "pretty prints actions" $ do
      render (HiValueAction (HiActionRead "file.txt")) `shouldBe` "read(\"file.txt\")"
      render (HiValueAction (HiActionWrite "file.txt" (BS.pack [0x61, 0x62, 0x63]))) `shouldBe` "write(\"file.txt\", [# 61 62 63 #])"
      render (HiValueAction (HiActionMkDir "mydir")) `shouldBe` "mkdir(\"mydir\")"
      render (HiValueAction (HiActionChDir "mydir")) `shouldBe` "cd(\"mydir\")"
      render (HiValueAction HiActionCwd) `shouldBe` "cwd"