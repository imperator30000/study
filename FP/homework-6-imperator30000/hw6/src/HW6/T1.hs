{-# LANGUAGE FlexibleContexts #-}

module HW6.T1
  ( BucketsArray
  , CHT (..)
  
  , newCHT
  , getCHT
  , putCHT
  , sizeCHT

  , initCapacity
  , loadFactor
  ) where

import Control.Concurrent.Classy (MonadConc (atomically), MonadSTM (newTVar, writeTVar), STM)
import Control.Concurrent.Classy.STM (TArray, TVar)
import Control.Concurrent.Classy.STM.TVar (readTVar)

import Control.Monad (when)
import Data.Array.MArray (getBounds, getElems, newArray, readArray, writeArray)
import Data.Hashable (Hashable (hash))
import qualified Data.List as List

-- | The initial capacity of the concurrent hash table.
initCapacity :: Int
initCapacity = 16

-- | The load factor that triggers resizing.
loadFactor :: Double
loadFactor = 0.75

-- | A bucket is represented as a list of key-value pairs.
type Bucket k v = [(k, v)]

-- | The array of buckets stored in the hash table.
type BucketsArray stm k v = TArray stm Int (Bucket k v)

-- | A concurrent hash table (CHT) data structure.
data CHT stm k v = CHT
  { chtBuckets :: TVar stm (BucketsArray stm k v)
  , chtSize    :: TVar stm Int
  }

-- | Compute the index of a bucket for a given key.
bucketIndex :: (Hashable k) => k -> Int -> Int
bucketIndex key capacity = hash key `mod` capacity

-- | Create a new concurrent hash table.
newCHT :: MonadConc m => m (CHT (STM m) k v)
newCHT = atomically $ do
    buckets <- newArray (0, initCapacity - 1) []
    bucketsVar <- newTVar buckets
    sizeVar <- newTVar 0
    return $ CHT bucketsVar sizeVar

-- | Retrieve the value associated with the given key from the hash table.
getCHT :: (MonadConc m, Hashable k) => k -> CHT (STM m) k v -> m (Maybe v)
getCHT key cht = atomically $ do
    buckets <- readTVar (chtBuckets cht)
    bounds <- getBounds buckets
    let capacity = snd bounds + 1
    let index = bucketIndex key capacity
    bucket <- readArray buckets index
    return $ lookup key bucket

-- | Insert a key-value pair into the hash table.
putCHT :: (MonadConc m, Hashable k) => k -> v -> CHT (STM m) k v -> m ()
putCHT key value cht = atomically $ do
    buckets <- readTVar (chtBuckets cht)
    size <- readTVar (chtSize cht)
    bounds <- getBounds buckets
    let capacity = snd bounds + 1
    let index = bucketIndex key capacity

    bucket <- readArray buckets index
    let updatedBucket = (key, value) : List.filter ((/= key) . fst) bucket
    writeArray buckets index updatedBucket

    when (length updatedBucket > length bucket) $
        writeTVar (chtSize cht) (size + 1)

    let load = fromIntegral (size + 1) / fromIntegral capacity
    when (load > loadFactor) $
        resizeCHT cht

-- | Resize the hash table to double its current capacity.
resizeCHT :: (MonadSTM stm, Hashable k) => CHT stm k v -> stm ()
resizeCHT cht = do
    oldBuckets <- readTVar (chtBuckets cht)
    bounds <- getBounds oldBuckets
    let oldCapacity = snd bounds + 1
    let newCapacity = oldCapacity * 2

    newBuckets <- newArray (0, newCapacity - 1) []

    elems <- getElems oldBuckets
    mapM_ (rehash newBuckets newCapacity) (concat elems)

    writeTVar (chtBuckets cht) newBuckets

-- | Helper function to redistribute
rehash :: (Hashable k, MonadSTM stm) => TArray stm Int (Bucket k v) -> Int -> (k, v) -> stm ()
rehash newBuckets newCapacity (key, value) = do
    let index = bucketIndex key newCapacity
    bucket <- readArray newBuckets index
    writeArray newBuckets index ((key, value) : bucket)

-- | Return the number of elements currently in the hash table.
sizeCHT :: MonadConc m => CHT (STM m) k v -> m Int
sizeCHT cht = atomically $ readTVar (chtSize cht)