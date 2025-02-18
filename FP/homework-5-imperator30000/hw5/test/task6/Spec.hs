import HW5.Parser (parse)
import HW5.Base (HiExpr(HiExprValue, HiExprApply))
import HW5.Base (HiValue(HiValueBytes, HiValueNumber, HiValueString, HiValueFunction, HiValueNull, HiValueList))
import HW5.Base (HiFun(HiFunList, HiFunPackBytes, HiFunUnpackBytes, HiFunEncodeUtf8, HiFunDecodeUtf8, HiFunZip, HiFunUnzip, HiFunSerialise, HiFunDeserialise))
import HW5.Base (HiError(HiErrorInvalidArgument, HiErrorArityMismatch))
import Test.Hspec (hspec, describe, it, shouldBe)
import qualified Data.ByteString as BS
import qualified Data.Text as Text
import Data.Sequence (fromList)
import Data.Word (Word8)
import Data.Ratio ((%))
import TestTH (evalIdentity, render)

main :: IO ()
main = hspec $ do
  describe "Parser" $ do
    it "parses byte array literals" $ do
      parse "[# 01 3f ec #]" `shouldBe`
        Right (HiExprValue (HiValueBytes (BS.pack [0x01, 0x3f, 0xec])))

      parse "[# #]" `shouldBe`
        Right (HiExprValue (HiValueBytes BS.empty))

    it "parses pack-bytes, unpack-bytes, encode-utf8, decode-utf8" $ do
      parse "pack-bytes([3, 255, 158])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunPackBytes))
        [HiExprApply (HiExprValue (HiValueFunction HiFunList))
          [HiExprValue (HiValueNumber (3 % 1)),
           HiExprValue (HiValueNumber (255 % 1)),
           HiExprValue (HiValueNumber (158 % 1))]])

      parse "unpack-bytes([# 10 20 30 #])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunUnpackBytes))
              [HiExprValue (HiValueBytes (BS.pack [0x10, 0x20, 0x30]))])

      parse "encode-utf8(\"Hello!\")" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunEncodeUtf8))
              [HiExprValue (HiValueString (Text.pack "Hello!"))])

      parse "decode-utf8([# 48 65 6c 6c 6f 21 #])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunDecodeUtf8))
              [HiExprValue (HiValueBytes (BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x21]))])

    it "parses compression and serialization functions" $ do
      parse "zip([# 48 65 6c 6c 6f 21 #])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunZip))
              [HiExprValue (HiValueBytes (BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x21]))])

      parse "unzip([# 78 9c 63 64 62 06 00 00 06 00 01 #])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunUnzip))
              [HiExprValue (HiValueBytes (BS.pack [0x78, 0x9c, 0x63, 0x64, 0x62, 0x06, 0x00, 0x00, 0x06, 0x00, 0x01]))])

      parse "serialise(42)" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunSerialise))
              [HiExprValue (HiValueNumber (42 % 1))])

      parse "deserialise([# 02 48 65 6c 6c 6f #])" `shouldBe`
        Right (HiExprApply (HiExprValue (HiValueFunction HiFunDeserialise))
              [HiExprValue (HiValueBytes (BS.pack [0x02, 0x48, 0x65, 0x6c, 0x6c, 0x6f]))])

  describe "Evaluator" $ do
    it "evaluates pack-bytes and unpack-bytes" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunPackBytes))
                  [HiExprValue (HiValueList (fromList [HiValueNumber 3, HiValueNumber 255, HiValueNumber 158]))])
        `shouldBe` Right (HiValueBytes (BS.pack [3, 255, 158]))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunUnpackBytes))
                  [HiExprValue (HiValueBytes (BS.pack [0x10, 0x20, 0x30]))])
        `shouldBe` Right (HiValueList (fromList [HiValueNumber 16, HiValueNumber 32, HiValueNumber 48]))

    it "evaluates encode-utf8 and decode-utf8" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunEncodeUtf8))
                  [HiExprValue (HiValueString (Text.pack "Hello!"))])
        `shouldBe` Right (HiValueBytes (BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x21]))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunDecodeUtf8))
                  [HiExprValue (HiValueBytes (BS.pack [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x21]))])
        `shouldBe` Right (HiValueString (Text.pack "Hello!"))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunDecodeUtf8))
                  [HiExprValue (HiValueBytes (BS.pack [0xc3, 0x28]))])
        `shouldBe` Right HiValueNull

    it "evaluates zip and unzip" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunUnzip))
              [HiExprApply (HiExprValue (HiValueFunction HiFunZip))
                [HiExprValue (HiValueBytes (BS.pack [0x78, 0xda, 0x63, 0x64, 0x62, 0x06, 0x00, 0x00, 0x0d, 0x00, 0x07]))]])
        `shouldBe` Right (HiValueBytes (BS.pack [0x78, 0xda, 0x63, 0x64, 0x62, 0x06, 0x00, 0x00, 0x0d, 0x00, 0x07]))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunZip))
              [HiExprApply (HiExprValue (HiValueFunction HiFunUnzip))
                [HiExprValue (HiValueBytes (BS.pack [0x78, 0xda, 0x63, 0x64, 0x62, 0x06, 0x00, 0x00, 0x0d, 0x00, 0x07]))]])
        `shouldBe` Right (HiValueBytes (BS.pack [0x78, 0xda, 0x63, 0x64, 0x62, 0x06, 0x00, 0x00, 0x0d, 0x00, 0x07]))

        


    it "evaluates serialise and deserialise" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunDeserialise))
              [HiExprApply (HiExprValue (HiValueFunction HiFunSerialise))
                [HiExprValue (HiValueNumber (42 % 1))]])
        `shouldBe` Right (HiValueNumber (42 % 1))

      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunSerialise))
              [HiExprApply (HiExprValue (HiValueFunction HiFunDeserialise))
                [HiExprValue (HiValueBytes (BS.pack [0x82, 0x00, 0x82, 0x01, 0x01]))]])
        `shouldBe` Right (HiValueBytes (BS.pack [0x82, 0x00, 0x82, 0x01, 0x01]))

    it "handles errors" $ do
      evalIdentity (HiExprApply (HiExprValue (HiValueFunction HiFunPackBytes))
                  [HiExprValue (HiValueList (fromList [HiValueNumber (999999)]))])
        `shouldBe` Left HiErrorInvalidArgument


  describe "Pretty printer" $ do
    it "pretty prints bytes" $ do
      render (HiValueBytes (BS.pack [0x01, 0x3f, 0xec]))
        `shouldBe` "[# 01 3f ec #]"
      render (HiValueBytes BS.empty) `shouldBe` "[#  #]"

    it "pretty prints functions" $ do
      render (HiValueFunction HiFunPackBytes) `shouldBe` "pack-bytes"
      render (HiValueFunction HiFunUnpackBytes) `shouldBe` "unpack-bytes"
      render (HiValueFunction HiFunEncodeUtf8) `shouldBe` "encode-utf8"
      render (HiValueFunction HiFunDecodeUtf8) `shouldBe` "decode-utf8"
      render (HiValueFunction HiFunZip) `shouldBe` "zip"
      render (HiValueFunction HiFunUnzip) `shouldBe` "unzip"
      render (HiValueFunction HiFunSerialise) `shouldBe` "serialise"
      render (HiValueFunction HiFunDeserialise) `shouldBe` "deserialise"