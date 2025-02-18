module HW1.T1
  ( Day (..)
  , afterDays
  , daysToParty
  , isWeekend
  , nextDay
  ) where

import Numeric.Natural (Natural)

data Day
  = Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday
  deriving (Show, Eq)

daysOfWeek :: [Day]
daysOfWeek = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]

nextDay :: Day -> Day
nextDay day = case dropWhile (/= day) daysOfWeek of
                (_:d:_) -> d
                _       -> Monday

afterDays :: Natural -> Day -> Day
afterDays n day
  | n == 0 = day
  | n < 7 = afterDays (n - 1) (nextDay day)
  | otherwise = afterDays (n `mod` 7) day

isWeekend :: Day -> Bool
isWeekend Saturday = True
isWeekend Sunday = True
isWeekend _ = False

daysToParty :: Day -> Natural
daysToParty Friday = 0
daysToParty day = daysToParty (nextDay day) + 1

