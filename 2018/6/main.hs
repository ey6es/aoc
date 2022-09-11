import qualified Data.Set as Set

manhattanDistance :: (Int, Int) -> (Int, Int) -> Int
manhattanDistance (a, b) (c, d) = abs (a - c) + abs (b - d)

readPair :: String -> (Int, Int)
readPair s =
  (read $ init $ head w, read $ last w)
  where w = words s

sumDistance :: (Int, Int) -> [(Int, Int)] -> Int
sumDistance t p = sum $ map (manhattanDistance t) p

addPoint :: [(Int, Int)] -> Set.Set (Int, Int) -> (Int, Int) -> Set.Set (Int, Int)
addPoint p s c
  | Set.member c s || (sumDistance c p >= 10000) = s
  | otherwise = foldl (addPoint p) (Set.insert c s) [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
  where (x, y) = c

main = do
  contents <- readFile "input.txt"
  let p = map readPair $ lines contents
      l = length p
      (xs, ys) = unzip p
      c = (sum xs `div` l, sum ys `div` l)
      points = addPoint p Set.empty c
  print $ Set.size points
