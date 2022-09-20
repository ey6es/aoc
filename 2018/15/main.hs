import qualified Data.Map as Map
import qualified Data.Set as Set

data Race = Elf | Goblin deriving (Eq, Show)

type Position = (Int, Int)

type Walls = Set.Set Position

type Units = Map.Map Position (Int, Race, Int)

foldChar :: Int -> (Walls, Units, Int) -> (Int, Char) -> (Walls, Units, Int)
foldChar y (w, u, id) (x, c)
  | c == '#' = (Set.insert (y, x) w, u, id)
  | c == 'E' = (w, Map.insert (y, x) (id, Elf, 200) u, id + 1)
  | c == 'G' = (w, Map.insert (y, x) (id, Goblin, 200) u, id + 1)
  | otherwise = (w, u, id)

foldLine :: (Walls, Units, Int) -> (Int, String) -> (Walls, Units, Int)
foldLine (w, u, id) (y, l) = foldl (foldChar y) (w, u, id) $ zip [0..] l

manhattanDistance :: Position -> Position -> Int
manhattanDistance (y, x) (y', x') = abs (y - y') + abs (x - x')

foldAttackPos :: Position -> Race -> (Position, Int) -> Position -> (Int, Race, Int) -> (Position, Int)
foldAttackPos p r (minp, minhp) p' (_, r', hp)
  | r' /= r && manhattanDistance p p' == 1 && hp < minhp = (p', hp)
  | otherwise = (minp, minhp)

execAttack :: Position -> Int -> Units -> (Units, Bool)
execAttack p a u
  | hp' <= 0 = (Map.delete p u, r == Elf)
  | otherwise = (Map.insert p (id, r, hp') u, False)
  where (id, r, hp) = u Map.! p
        hp' = hp - a

type Moves = Map.Map Position (Int, Position)
type Fringe = Set.Set Position

getNextPos :: Position -> Position -> Moves -> Position
getNextPos p p' m
  | p == p' = (0, 0)
  | p'' == p = p'
  | otherwise = getNextPos p p'' m
  where (_, p'') = m Map.! p'

foldFringe :: Moves -> (Position, Int) -> Position -> (Position, Int)
foldFringe m (minp, mind) p
  | d < mind = (p, d)
  | otherwise = (minp, mind)
  where (d, _) = m Map.! p

maybeAddNeighbor :: Position -> Position -> Walls -> Units -> (Moves, Fringe) -> Position -> (Moves, Fringe)
maybeAddNeighbor p (y, x) w u (m, f) (oy, ox)
  | Set.member p' w ||
    Map.member p' u ||
    Map.member p' m && Set.notMember p' f ||
    d' > ed ||
    d' == ed && (getNextPos p ep m) < (getNextPos p (y, x) m) = (m, f)
  | otherwise = (Map.insert p' (d', (y, x)) m, Set.insert p' f)
  where p' = (y + oy, x + ox)
        (d, _) = m Map.! (y, x)
        d' = d + 1
        (ed, ep) = Map.findWithDefault (10000, (0, 0)) p' m

addNeighbors :: Position -> Position -> Walls -> Units -> Moves -> Fringe -> (Moves, Fringe)
addNeighbors p p' w u m f = foldl (maybeAddNeighbor p p' w u) (m, f) [(-1, 0), (0, -1), (0, 1), (1, 0)]

findMovePos :: Position -> Race -> Walls -> Units -> Moves -> Fringe -> Position
findMovePos p r w u m f
  | p' == (0, 0) = (0, 0)
  | Map.foldlWithKey (\v p'' (_, r', _) -> v || r /= r' && manhattanDistance p' p'' == 1) False u = getNextPos p p' m
  | otherwise = findMovePos p r w u m' f'
  where (p', _) = Set.foldl (foldFringe m) ((0, 0), 10000) f
        (m', f') = addNeighbors p p' w u m $ Set.delete p' f

data Status = Continuing | Aborted | Ended deriving (Eq)

execUnit :: Int -> Walls -> (Units, Status) -> (Position, (Int, Race, Int)) -> (Units, Status)
execUnit ea w (u, status) (p, (id, _, _))
  | status /= Continuing = (u, status)
  | Map.notMember p u = (u, Continuing)
  | id /= id' = (u, Continuing)
  | getSingleRaceHP u > 0 = (u, Ended)
  | attackPos /= (0, 0) = (u'', if abort then Aborted else Continuing)
  | otherwise = (u', Continuing)
  where (id', r, hp) = u Map.! p
        movePos = findMovePos p r w u (Map.singleton p (0, (0, 0))) (Set.singleton p)
        (u', p') = if movePos /= (0, 0) then (Map.insert movePos (id, r, hp) $ Map.delete p u, movePos) else (u, p)
        (attackPos, _) = Map.foldlWithKey (foldAttackPos p' r) ((0, 0), 1000) u'
        (u'', abort) = execAttack attackPos (if r == Elf then ea else 3) u'

execRound :: Int -> Walls -> Units -> (Units, Status)
execRound ea w u = foldl (execUnit ea w) (u, Continuing) $ Map.toList u

getSingleRaceHP :: Units -> Int
getSingleRaceHP u
  | all (\r' -> r' == r) rs = sum hps
  | otherwise = 0
  where (_, rs, hps) = unzip3 $ Map.elems u
        r = head rs

getResult :: Int -> Walls -> Units -> Int -> Int
getResult ea w u i
  | status == Aborted = 0
  | status == Ended = hp * i
  | otherwise = getResult ea w u' (i + 1)
  where (u', status) = execRound ea w u
        hp = getSingleRaceHP u'

getNoLossResult :: Int -> Walls -> Units -> Int
getNoLossResult ea w u
  | result > 0 = result
  | otherwise = getNoLossResult (ea + 1) w u
  where result = getResult ea w u 0

main = do
  contents <- readFile "input.txt"
  let (w, u, _) = foldl foldLine (Set.empty, Map.empty, 0) $ zip [0..] $ lines contents
  print $ getNoLossResult 4 w u
