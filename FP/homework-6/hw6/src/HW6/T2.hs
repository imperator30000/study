{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}


module HW6.T2
  ( TSet

  , Contains
  , Add
  , Delete
  ) where

import GHC.TypeLits

-- | `TSet` is a type-level list of `Symbol`s.
type TSet = [Symbol]

-- | Check if a symbol is contained in a type-level set.
type family Contains (name :: Symbol) (set :: TSet) :: Bool where
  Contains _ '[]         = 'False
  Contains name (name ': _) = 'True
  Contains name (_ ': xs)  = Contains name xs

-- | Remove a symbol from a type-level set.
type family Delete (name :: Symbol) (set :: TSet) :: TSet where
  Delete _ '[]         = '[]
  Delete name (name ': xs) = xs
  Delete name (x ': xs)    = x ': Delete name xs

-- | Add a symbol to a type-level set.
type family Add (v :: Symbol) (set :: TSet) :: TSet where
  Add v '[] = '[v]
  Add v (v ': xs) = v ': xs
  Add v (x ': xs) = x ': Add v xs
