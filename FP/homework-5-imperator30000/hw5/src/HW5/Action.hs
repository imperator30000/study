{- |
Module      : HW5.Action
Description : Implementation of HiMonad for executing HiAction operations with permission-based control
Maintainer  : vadim09531@yandex.ru

This module provides the `HIO` monad for executing `HiAction` operations from the Hi language.
It enforces a permission model to control read, write and time-based operations. The module implements:
* File and directory operations (read, write, list, change directory, etc.)
* Time operations (fetching the current time)
* Random number generation
* Controlled standard output (echo)
-}
module HW5.Action
  ( HiPermission(..)        -- ^ Set of possible permissions needed to execute HiAction tasks
  , PermissionException(..) -- ^ Exception thrown when a required permission is missing
  , HIO(..)                 -- ^ A monad for executing actions with controlled permissions
  ) where


import HW5.Base
import Control.Exception (Exception, throwIO)
import qualified Data.ByteString as BS
import System.Directory
import Data.Set (Set)
import qualified Data.Set as Set
import qualified Data.Sequence as Seq
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Encoding
import Control.Monad (ap, liftM, unless)
import Data.Time.Clock (getCurrentTime)
import System.Random (randomRIO)


{- |
Represents different types of permissions required to execute specific `HiAction` operations.
Each permission allows execution of a specific category of actions:

* 'AllowRead' — gives permission to read files and directories.
* 'AllowWrite' — gives permission to write files and create directories.
* 'AllowTime' — gives permission to access the current system time.
-}
data HiPermission =
    AllowRead   -- ^ Permits reading files and directories
  | AllowWrite  -- ^ Permits writing to files and creating directories
  | AllowTime   -- ^ Permits fetching the current system time
  deriving (Eq, Ord, Show)

{- |
An exception type that is thrown when an action requires a permission
that is not included in the available set of permissions.
-}
data PermissionException =
  PermissionRequired HiPermission
  deriving (Show)

instance Exception PermissionException


{- |
The `HIO` monad is used to execute `HiAction` operations with strict permission control. 

* Each `HIO` action has access to a `Set HiPermission`, which determines the available permissions.
* Operations are executed in the `IO` monad.

This monad ensures that certain actions (e.g., reading or writing files, changing directories) 
cannot run unless the corresponding permission is explicitly granted.
-}
newtype HIO a = HIO { runHIO :: Set HiPermission -> IO a }

instance Applicative HIO where
  pure x = HIO $ \_ -> return x
  (<*>) = ap

instance Functor HIO where
  fmap = liftM

instance Monad HIO where
  HIO ma >>= f = HIO $ \perm -> do
    a <- ma perm
    runHIO (f a) perm

{- |
Verifies if the required permission is present in the current set of permissions. 
If the required permission is missing, a `PermissionException` is thrown.
-}
checkPermission :: HiPermission -> Set HiPermission -> IO ()
checkPermission requiredPermission currentPermissions = 
  unless (Set.member requiredPermission currentPermissions) $
    throwIO (PermissionRequired requiredPermission)

{- |
Provides an instance of the `HiMonad` class for the `HIO` monad, enabling the execution
of `HiAction` tasks.

The `runAction` function takes an action and the current set of permissions,
then ensures the action is executed only if the permissions allow it.

Supported actions:
* 'HiActionCwd' — gets the current working directory.
* 'HiActionNow' — gets the current system time.
* 'HiActionChDir' — changes the current working directory.
* 'HiActionMkDir' — creates a new directory.
* 'HiActionRead' — reads data from a file or lists a directory's contents.
* 'HiActionWrite' — writes data to a file.
* 'HiActionRand' — generates a random number in the given range.
* 'HiActionEcho' — prints text to the standard output.

Errors:
- Throws `PermissionException` if the required permission is not present.
-}
instance HiMonad HIO where
  runAction action = HIO $ \permissions -> case action of
    HiActionCwd -> do
      checkPermission AllowRead permissions
      cwd <- getCurrentDirectory
      return $ HiValueString (Text.pack cwd)

    HiActionNow -> do
      checkPermission AllowTime permissions
      currentTime <- getCurrentTime
      return $ HiValueTime currentTime
      
    HiActionChDir path -> do
      checkPermission AllowRead permissions
      setCurrentDirectory path
      return HiValueNull
      
    HiActionMkDir path -> do
      checkPermission AllowWrite permissions
      createDirectory path
      return HiValueNull
      
    HiActionRead path -> do
      checkPermission AllowRead permissions
      isDir <- doesDirectoryExist path
      if isDir
        then do
          contents <- listDirectory path
          return . HiValueList $ Seq.fromList (map (HiValueString . Text.pack) contents)
        else do
          content <- BS.readFile path
          case Encoding.decodeUtf8' content of
            Right text -> return $ HiValueString text
            Left _     -> return $ HiValueBytes content

    HiActionWrite path content -> do
      checkPermission AllowWrite permissions
      BS.writeFile path content
      return HiValueNull

    HiActionRand from to -> do
      num <- randomRIO (from, to)
      return $ HiValueNumber (toRational num)

    HiActionEcho text -> do
        checkPermission AllowWrite permissions
        putStrLn (Text.unpack text)
        return HiValueNull  
