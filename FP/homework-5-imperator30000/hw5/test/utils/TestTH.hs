{-# LANGUAGE TemplateHaskell #-}

module TestTH (evalIdentity, render, fullEvaluate) where

import Language.Haskell.TH
import Control.Monad.Identity (Identity)
import Data.Maybe (isJust)
import HW5.Base(HiExpr(..), HiError(..), HiValue(..))
import Prettyprinter.Render.String (renderString)
import Control.Monad.Identity (runIdentity)
import Prettyprinter (layoutPretty, defaultLayoutOptions)
import HW5.Base
import HW5.Evaluator (eval)
import HW5.Pretty (prettyValue)
import HW5.Parser (parse)


$(do
    maybeHiMonad <- lookupTypeName "HW5.Base.HiMonad"
    case maybeHiMonad of
      Just hiMonadName -> do
        let identityInstance = InstanceD
              Nothing
              []
              (AppT (ConT hiMonadName) (ConT ''Identity))
              [FunD 'HW5.Base.runAction [Clause [WildP] 
                                (NormalB (AppE (VarE 'error) (LitE (StringL "runAction should not be called in Identity context for tests")))) 
                                []]]
        pure [identityInstance]
      Nothing -> pure [])

evalIdentity :: HiExpr -> Either HiError HiValue
evalIdentity expr = runIdentity $ eval expr
render :: HiValue -> String
render = renderString . layoutPretty defaultLayoutOptions . prettyValue

fullEvaluate :: String -> Either String String
fullEvaluate input = case parse input of
  Left err      -> Left (show err)
  Right hiExpr  -> case evalIdentity hiExpr of
                     Left evalErr   -> Left (show evalErr)
                     Right hiValue  -> Right (render hiValue)