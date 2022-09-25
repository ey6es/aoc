import qualified Data.Map as Map
import qualified Data.Set as Set

type Cache = Map.Map (Int, Int) Int

getGeologicIndex :: Int -> (Int, Int) -> (Int, Int) -> Cache -> (Int, Cache)
getGeologicIndex d t (0, 0) c = (0, c)
getGeologicIndex d t (x, 0) c = (x * 16807, c)
getGeologicIndex d t (0, y) c = (y * 48271, c)
getGeologicIndex d t (x, y) c
  | (x, y) == t = (0, c)
  | otherwise = (ex * ey, c'')
  where (ex, c') = getErosionLevel d t (x - 1, y) c
        (ey, c'') = getErosionLevel d t (x, y - 1) c'

getErosionLevel :: Int -> (Int, Int) -> (Int, Int) -> Cache -> (Int, Cache)
getErosionLevel d t p c
  | cached /= 0 = (cached, c)
  | otherwise = (l, Map.insert p l c')
  where cached = Map.findWithDefault 0 p c
        (i, c') = getGeologicIndex d t p c
        l = (i + d) `mod` 20183

getRiskLevel :: Int -> (Int, Int) -> (Int, Int) -> Cache -> (Int, Cache)
getRiskLevel d t p c = (l `mod` 3, c')
                       where (l, c') = getErosionLevel d t p c

data Equipment = Torch | Gear | Neither deriving (Eq, Ord)

type Position = ((Int, Int), Equipment)

distance :: Position -> Position -> Int
distance ((x0, y0), e0) ((x1, y1), e1)
  | e0 == e1 = md
  | otherwise = md + 7
  where md = abs (x0 - x1) + abs (y0 - y1)

type Option = (Int, Int, Position)

foldOffset :: Int -> (Int, Int) -> Position -> ([Position], Cache) -> (Int, Int) -> ([Position], Cache)
foldOffset d t ((x, y), e) (n, c) (dx, dy)
  | x' < 0 || y' < 0 = (n, c)
  | case l of 0 -> e == Neither; 1 -> e == Torch; 2 -> e == Gear = (n, c')
  | otherwise = (((x', y'), e):n, c')
  where (x', y') = (x + dx, y + dy)
        (l, c') = getRiskLevel d t (x', y') c

getNeighbors :: Int -> (Int, Int) -> Cache -> Position -> ([Position], Cache)
getNeighbors d t c ((x, y), e) = foldl (foldOffset d t ((x, y), e)) ([((x, y), e')], c') [(0, -1), (0, 1), (1, 0), (-1, 0)]
  where (l, c') = getRiskLevel d t (x, y) c
        e' = case l of 0 -> if e == Gear then Torch else Gear
                       1 -> if e == Gear then Neither else Gear
                       2 -> if e == Torch then Neither else Torch

foldNeighbor :: (Int, Int) -> Int -> Position -> Set.Set Position -> Set.Set Option -> Position -> Set.Set Option
foldNeighbor t md mp v o p
  | Set.member p v = o
  | otherwise = Set.insert (d + distance p (t, Torch), d, p) o
  where d = md + distance mp p

getShortestDistance :: Int -> (Int, Int) -> Cache -> Set.Set Position -> Set.Set Option -> Int
getShortestDistance d t c v o
  | mp == (t, Torch) = md
  | otherwise = getShortestDistance d t c' v' o'
  where (me, md, mp) = Set.findMin o
        v' = Set.insert mp v
        (n, c') = getNeighbors d t c mp
        o' = foldl (foldNeighbor t md mp v) (Set.delete (me, md, mp) o) n

main = do
  contents <- readFile "input.txt"
  let l = lines contents
      d = read $ head $ tail $ words $ head l :: Int
      (b, a) = span (/=',') $ head $ tail $ words $ head $ tail l
      t = (read b, read $ tail a)
      s = ((0, 0), Torch)
  print $ getShortestDistance d t Map.empty Set.empty $ Set.singleton (distance s (t, Torch), 0, s)
