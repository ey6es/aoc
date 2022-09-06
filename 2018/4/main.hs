import Data.List
import qualified Data.IntMap as IntMap
import Data.Time
import Data.Time.Clock

data Action = Guard Int | Sleeps | Wakes deriving (Eq, Ord, Show)

type Event = (LocalTime, Action)

readEvent :: String -> Event
readEvent s
  | l == "shift" = (t, Guard $ read $ tail $ head $ drop 3 w)
  | l == "asleep" = (t, Sleeps)
  | otherwise = (t, Wakes)
  where time = parseTimeM False defaultTimeLocale "[%0Y-%m-%d %H:%M" $ takeWhile (/= ']') s :: Maybe LocalTime
        t = case time of Just t -> t; Nothing -> error "Invalid timestamp"
        w = words s
        l = last w

nextMinute :: LocalTime -> LocalTime
nextMinute t = utcToLocalTime utc $ addUTCTime 60 $ localTimeToUTC utc t

minuteOf :: LocalTime -> Int
minuteOf t = todMin $ localTimeOfDay t

addMinutes :: LocalTime -> LocalTime -> IntMap.IntMap Int -> IntMap.IntMap Int
addMinutes t t' m
  | t == t' = m
  | otherwise = addMinutes (nextMinute t) t' $ IntMap.insertWith (+) (minuteOf t) 1 m

type RunningCount = (Int, Maybe LocalTime, IntMap.IntMap (IntMap.IntMap Int))

countMinutes :: RunningCount -> Event -> RunningCount
countMinutes (_, _, m) (_, Guard id) = (id, Nothing, m)
countMinutes (id, _, m) (t, Sleeps) = (id, Just t, m)
countMinutes (id, Just t, m) (t', Wakes) = (id, Just t', IntMap.insert id minutes m)
  where minutes = addMinutes t t' $ IntMap.findWithDefault IntMap.empty id m

getHighestIdTotal :: (Int, Int, Int) -> Int -> IntMap.IntMap Int -> (Int, Int, Int)
getHighestIdTotal (hid, hm, hv) id map =
  IntMap.foldlWithKey (\(hid, hm, hv) m v -> if v > hv then (id, m, v) else (hid, hm, hv)) (hid, hm, hv) map

main = do
  contents <- readFile "input.txt"
  let events = sort $ map readEvent $ lines contents
      (_, _, minutes) = foldl countMinutes (0, Nothing, IntMap.empty) $ events
      (id, minute, _) = IntMap.foldlWithKey getHighestIdTotal (0, 0, 0) minutes
  print $ id * minute
