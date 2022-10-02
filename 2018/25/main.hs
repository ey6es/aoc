import qualified Data.Set as Set

type Position = (Int, Int, Int, Int)

manhattanDistance :: Position -> Position -> Int
manhattanDistance (x0, y0, z0, w0) (x1, y1, z1, w1) = abs (x0 - x1) + abs (y0 - y1) + abs (z0 - z1) + abs (w0 - w1)

readPosition :: String -> Position
readPosition s = (read x, read y, read z, read w)
  where (x, s') = span (/=',') s
        (y, s'') = span (/=',') $ tail s'
        (z, s''') = span (/=',') $ tail s''
        w = tail s'''

foldConstellation :: Position -> Position -> Set.Set Position -> Set.Set Position
foldConstellation p p' ps
  | manhattanDistance p p' <= 3 = removeConstellation ps p'
  | otherwise = ps

removeConstellation :: Set.Set Position -> Position -> Set.Set Position
removeConstellation ps p = Set.fold (foldConstellation p) ps' ps'
  where ps' = Set.delete p ps

countConstellations :: Set.Set Position -> Int
countConstellations ps
  | Set.null ps = 0
  | otherwise = 1 + countConstellations ps'
  where ps' = removeConstellation ps $ Set.findMin ps

main = do
  contents <- readFile "input.txt"
  print $ countConstellations $ Set.fromList $ map readPosition $ lines contents
