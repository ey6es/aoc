import qualified Data.Foldable as Foldable
import qualified Data.IntSet as IntSet
import qualified Data.Sequence as Seq

type Position = (Int, Int, Int)
type Entry = (Position, Int)

readEntry :: String -> Entry
readEntry s = ((read x, read y, read z), read r)
  where s0 = dropWhile (/='<') s
        (x, s1) = span (/=',') $ tail s0
        (y, s2) = span (/=',') $ tail s1
        (z, s3) = span (/='>') $ tail s2
        r = tail $ dropWhile (/='=') s3

dirs :: [Position]
dirs = [(1, 1, 1), (1, 1, -1), (1, -1, 1), (-1, 1, 1)]

type Range = (Int, Int)

maxRanges :: [Range]
maxRanges = [(minBound, maxBound), (minBound, maxBound), (minBound, maxBound), (minBound, maxBound)]

getRange :: Entry -> Position -> Range
getRange ((x, y, z), r) (a, b, c) = (d - r, d + r)
  where d = x*a + y*b + z*c

type Endpoint = (Int, Bool, Int)

foldEndpoints :: Position -> Seq.Seq Endpoint -> Int -> Entry -> Seq.Seq Endpoint
foldEndpoints dir eps id e = eps Seq.|> (l, False, id) Seq.|> (u, True, id)
  where (l, u) = getRange e dir

foldSets :: (IntSet.IntSet, Seq.Seq IntSet.IntSet) -> Endpoint -> (IntSet.IntSet, Seq.Seq IntSet.IntSet)
foldSets (s, ss) (v, False, id) = (IntSet.insert id s, ss Seq.|> s)
foldSets (s, ss) (v, True, id) = (IntSet.delete id s, ss Seq.|> s)

getSets :: Seq.Seq Entry -> Position -> [IntSet.IntSet]
getSets es dir = Foldable.toList ss''
  where eps = Seq.sort $ Seq.foldlWithIndex (foldEndpoints dir) Seq.empty es
        (_, ss) = Foldable.foldl foldSets (IntSet.empty, Seq.empty) eps
        ss' = Seq.filter (\s -> not $ Foldable.foldl (\v s' -> v || IntSet.isProperSubsetOf s s') False ss) ss
        ss'' = Seq.sortBy (\s0 s1 -> compare (IntSet.size s1) (IntSet.size s0)) ss'

foldIntersection :: IntSet.IntSet -> (IntSet.IntSet, IntSet.IntSet, IntSet.IntSet, IntSet.IntSet) -> IntSet.IntSet
foldIntersection l (a, b, c, d)
  | IntSet.size i > IntSet.size l = i
  | otherwise = l
  where i = IntSet.intersection d $ IntSet.intersection c $ IntSet.intersection a b

getRanges :: Entry -> [Range]
getRanges e = map (getRange e) dirs

intersectRange :: (Range, Range) -> Range
intersectRange ((l0, u0), (l1, u1)) = (max l0 l1, min u0 u1)

intersectRanges :: Seq.Seq Entry -> Int -> [Range] -> [Range]
intersectRanges es i r = map intersectRange $ zip r $ getRanges $ Seq.index es i

getPosition :: (Int, Int, Int, Int) -> Position
getPosition (v0, v1, v2, v3) = ((v1 + v2) `div` 2, (v1 + v3) `div` 2, (v2 + v3) `div` 2)

manhattanDistance :: Position -> Position -> Int
manhattanDistance (x0, y0, z0) (x1, y1, z1) = abs (x0 - x1) + abs (y0 - y1) + abs (z0 - z1)

getPositions :: [Range] -> [Position]
getPositions [(l0, u0), (l1, u1), (l2, u2), (l3, u3)]
  = [getPosition (v0, v1, v2, v3) | v0 <- [l0, u0], v1 <- [l1, u1], v2 <- [l2, u2], v3 <- [l3, u3]]

foldNearest :: Position -> Position -> Position
foldNearest p p'
  | manhattanDistance p' (0, 0, 0) > manhattanDistance p (0, 0, 0) = p'
  | otherwise = p

foldInRange :: Position -> IntSet.IntSet -> Int -> Entry -> IntSet.IntSet
foldInRange p is id (p', r)
  | manhattanDistance p p' <= r = IntSet.insert id is
  | otherwise = is

getInRange :: Seq.Seq Entry -> Position -> IntSet.IntSet
getInRange es p = Seq.foldlWithIndex (foldInRange p) IntSet.empty es

isValid :: Seq.Seq Entry -> IntSet.IntSet -> Position -> Bool
isValid es i p = i == i'
  where i' = getInRange es p

getNearestValidPosition :: Seq.Seq Entry -> IntSet.IntSet -> [Position] -> Position
getNearestValidPosition es i ps = foldl1 foldNearest $ filter (isValid es i) ps

main = do
  contents <- readFile "input.txt"
  let es = Seq.fromList $ map readEntry $ lines contents
      s = map (getSets es) dirs
      i = foldl foldIntersection IntSet.empty [(a, b, c, d) | a <- s !! 0, b <- s !! 1, c <- s !! 2, d <- s !! 3]
      r = IntSet.fold (intersectRanges es) maxRanges i
      n = getNearestValidPosition es i $ getPositions r
  print n
  print $ manhattanDistance n (0, 0, 0)
