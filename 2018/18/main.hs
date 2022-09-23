import qualified Data.Map as Map
import Debug.Trace

type State = Map.Map (Int, Int) Char

foldLine :: State -> (Int, String) -> State
foldLine s (y, l) = foldl (\s' (x, c) -> Map.insert (y, x) c s') s $ zip [0..] l

foldNeighbor :: State -> (Int, Int) -> (Int, Int) -> (Int, Int)
foldNeighbor s (t, l) (y, x)
  | c == '|' = (t + 1, l)
  | c == '#' = (t, l + 1)
  | otherwise = (t, l)
  where c = Map.findWithDefault '.' (y, x) s

countNeighbors :: (Int, Int) -> State -> (Int, Int)
countNeighbors (y, x) s = foldl (foldNeighbor s) (0, 0) [(y + oy, x + ox) | oy <- [-1..1], ox <- [-1..1], oy /= 0 || ox /= 0]

nextChar :: (Int, Int) -> Char -> State -> Char
nextChar (y, x) '.' s
  | t >= 3 = '|'
  | otherwise = '.'
  where (t, l) = countNeighbors (y, x) s
nextChar (y, x) '|' s
  | l >= 3 = '#'
  | otherwise = '|'
  where (t, l) = countNeighbors (y, x) s
nextChar (y, x) '#' s
  | t == 0 || l == 0 = '.'
  | otherwise = '#'
  where (t, l) = countNeighbors (y, x) s

step :: State -> State
step s = Map.foldlWithKey (\s' (y, x) c -> Map.insert (y, x) (nextChar (y, x) c s) s') Map.empty s

findRepeat :: State -> Int -> Map.Map State Int -> (Int, Int)
findRepeat s i p
  | i' /= (-1) = (i', i)
  | otherwise = findRepeat s' (i + 1) p'
  where i' = Map.findWithDefault (-1) s p
        s' = step s
        p' = Map.insert s i p

runSteps :: State -> Int -> State
runSteps s i
  | i == 0 = s
  | otherwise = runSteps s' (i - 1)
  where s' = step s

main = do
  contents <- readFile "input.txt"
  let s = foldl foldLine Map.empty $ zip [0..] $ lines contents
      (i', i'') = findRepeat s 0 Map.empty
      s' = runSteps s (i' + (1000000000 - i') `mod` (i'' - i'))
      ts = Map.size $ Map.filter (=='|') s'
      ls = Map.size $ Map.filter (=='#') s'
  print $ ts * ls
