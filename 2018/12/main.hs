import qualified Data.IntSet as IntSet
import Data.List
import Data.Maybe

foldRule :: IntSet.IntSet -> String -> IntSet.IntSet
foldRule r l
  | t == '#' = IntSet.insert v r
  | otherwise = r
  where w = words l
        t = head $ last w
        v = foldl (\v c -> v * 2 + (if c == '#' then 1 else 0)) 0 $ head w

foldState :: IntSet.IntSet -> IntSet.IntSet -> IntSet.IntSet -> Int -> IntSet.IntSet
foldState r s s' x
  | IntSet.member v r = IntSet.insert x s'
  | otherwise = s'
  where v = foldl (\v x -> v * 2 + (if IntSet.member x s then 1 else 0)) 0 [x - 2 .. x + 2]

updateStates :: IntSet.IntSet -> IntSet.IntSet -> IntSet.IntSet
updateStates r s = foldl (foldState r s) IntSet.empty [IntSet.findMin s - 2 .. IntSet.findMax s + 2]

diffs :: [Int] -> [Int]
diffs (_:[]) = []
diffs (a:b:rest) = (b - a):(diffs (b:rest))

minSep :: IntSet.IntSet -> Int
minSep s = minimum $ diffs $ IntSet.toList s

main = do
  contents <- readFile "input.txt"
  let l = lines contents
      (_, s) = foldl (\(p, s) c -> (p + 1, if c == '#' then IntSet.insert p s else s)) (0, IntSet.empty) $ last $ words $ head l
      r = foldl foldRule IntSet.empty $ drop 2 l
      states = scanl (\(i, s) i' -> (i', updateStates r s)) (0, s) [1..]
      (i', s') = fromMaybe (0, s) $ find (\(_, s) -> minSep s >= 4) states
  print $ (sum $ IntSet.toList s') + ((50000000000 - i') * IntSet.size s')
