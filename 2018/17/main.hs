import qualified Data.Set as Set
import Debug.Trace

type Clay = Set.Set (Int, Int)

foldClay :: Clay -> String -> Clay
foldClay c l
  | a == 'x' = foldl (\c y -> Set.insert (y, value) c) c range
  | otherwise = foldl (\c x -> Set.insert (value, x) c) c range
  where a = head l
        l' = dropWhile (/= '=') l
        (v, l'') = span (/= ',') $ tail l'
        l''' = dropWhile (/= '=') $ l''
        (s, l'''') = span (/= '.') $ tail l'''
        e = tail $ tail l''''
        value = read v
        range = [read s .. read e]

type Affected = Set.Set (Int, Int)

data BoundaryType = Wall | Edge deriving (Eq)

findBoundary :: (Int, Int) -> Int -> Clay -> (BoundaryType, Int)
findBoundary (y, x) d c
  | Set.member (y, x') c = (Wall, x)
  | Set.notMember (y + 1, x') c = (Edge, x)
  | otherwise = findBoundary (y, x') d c
  where x' = x + d

findBottom :: (Int, Int) -> Clay -> (Bool, Int)
findBottom (y, x) c
  | y' > maxy = (False, y)
  | Set.member (y', x) c = (True, y)
  | otherwise = findBottom (y', x) c
  where y' = y + 1
        (maxy, _) = Set.findMax c

type Visited = Set.Set (Int, Int)

spread :: (Int, Int) -> Clay -> Affected -> Visited -> (Clay, Affected, Visited)
spread (y, x) c a v
  | lbt == Wall && rbt == Wall = (foldl (\c' x' -> Set.insert (y, x') c') c [lbx..rbx], a', v)
  | lbt == Wall = (rc, ra, rv)
  | rbt == Wall = (lc, la, lv)
  | otherwise = (cc, ca, cv)
  where (lbt, lbx) = findBoundary (y, x) (-1) c
        (rbt, rbx) = findBoundary (y, x) 1 c
        a' = foldl (\a' x' -> Set.insert (y, x') a') a [lbx..rbx]
        (rc, ra, rv) = drip (y, rbx + 1) c a' v
        (lc, la, lv) = drip (y, lbx - 1) c a' v
        (cc, ca, cv) = drip (y, rbx + 1) lc la lv

drip :: (Int, Int) -> Clay -> Affected -> Visited -> (Clay, Affected, Visited)
drip (y, x) c a v
  | Set.member (y, x) v = (c, a, v)
  | b = spread (by, x) c a' v'
  | otherwise = (c, a', v')
  where (b, by) = findBottom (y, x) c
        v' = Set.insert (y, x) v
        (miny, _) = Set.findMin c
        a' = foldl (\a' y' -> Set.insert (y', x) a') a [max miny y .. by]

dripUntilFinished :: (Int, Int) -> Clay -> Affected -> (Clay, Affected)
dripUntilFinished (y, x) c a
  | Set.size a == Set.size a' && Set.size c == Set.size c' = (c, a)
  | otherwise = dripUntilFinished (y, x) c' a'
  where (c', a', _) = drip (y, x) c a Set.empty

main = do
  contents <- readFile "input.txt"
  let c = foldl foldClay Set.empty $ lines contents
      (c', a') = dripUntilFinished (0, 500) c Set.empty
  print (Set.size c' - Set.size c)
