import qualified Data.Map as Map
import qualified Data.Set as Set

data PathElement = Direction Char | Choice [[PathElement]] deriving (Show)

parseChoices :: String -> ([[PathElement]], String)
parseChoices s
  | head r == '|' = (p : c, r')
  | otherwise = ([p], tail r)
  where (p, r) = parsePath s
        (c, r') = parseChoices $ tail r

parsePath :: String -> ([PathElement], String)
parsePath ('^':r) = parsePath r
parsePath ('$':_) = ([], "")
parsePath ('(':r) = (Choice c : p', r'')
                    where (c, r') = parseChoices r
                          (p', r'') = parsePath r'
parsePath ('|':r) = ([], '|':r)
parsePath (')':r) = ([], ')':r)
parsePath (d:r) = (Direction d : p, r')
                  where (p, r') = parsePath r

type Connections = Map.Map (Int, Int) (Set.Set (Int, Int))

addConnection :: (Int, Int) -> (Int, Int) -> Connections -> Connections
addConnection p p' c = Map.insertWith Set.union p (Set.singleton p') c'
                       where c' = Map.insertWith Set.union p' (Set.singleton p) c

addPaths :: (Int, Int) -> [[PathElement]] -> Connections -> (Connections, Set.Set (Int, Int))
addPaths (y, x) [] c = (c, Set.empty)
addPaths (y, x) (p:r) c = (c'', Set.union s s')
                          where (c', s) = addPath (y, x) p c
                                (c'', s') = addPaths (y, x) r c'

foldPath :: [PathElement] -> (Int, Int) -> (Connections, Set.Set (Int, Int)) -> (Connections, Set.Set (Int, Int))
foldPath r (y, x) (c, s) = (c', Set.union s s')
                           where (c', s') = addPath (y, x) r c

addPath :: (Int, Int) -> [PathElement] -> Connections -> (Connections, Set.Set (Int, Int))
addPath (y, x) [] c = (c, Set.singleton (y, x))
addPath (y, x) (Direction 'N':r) c = addPath (y - 1, x) r $ addConnection (y, x) (y - 1, x) c
addPath (y, x) (Direction 'S':r) c = addPath (y + 1, x) r $ addConnection (y, x) (y + 1, x) c
addPath (y, x) (Direction 'E':r) c = addPath (y, x + 1) r $ addConnection (y, x) (y, x + 1) c
addPath (y, x) (Direction 'W':r) c = addPath (y, x - 1) r $ addConnection (y, x) (y, x - 1) c
addPath (y, x) (Choice ps:r) c = Set.fold (foldPath r) (c', Set.empty) s
                                 where (c', s) = addPaths (y, x) ps c

type Distances = Map.Map (Int, Int) Int
type Fringe = Set.Set (Int, Int)

foldMin :: Distances -> (Int, Int) -> ((Int, Int), Int) -> ((Int, Int), Int)
foldMin d p (minp, mind)
  | pd < mind = (p, pd)
  | otherwise = (minp, mind)
  where pd = d Map.! p

foldConnection :: Int -> (Int, Int) -> (Distances, Fringe) -> (Distances, Fringe)
foldConnection pd p (d, f)
  | Set.member p f || ed < 100000 = (d', f)
  | otherwise = (d', Set.insert p f)
  where ed = Map.findWithDefault 100000 p d
        d' = if pd < ed then Map.insert p pd d else d

getOverThousandCount :: Connections -> Distances -> Fringe -> Int
getOverThousandCount c d f
  | mind == 100000 = length $ filter (>=1000) $ Map.elems d
  | otherwise = getOverThousandCount c d' f'
  where (minp, mind) = Set.fold (foldMin d) ((0, 0), 100000) f
        (d', f') = Set.fold (foldConnection (mind + 1)) (d, Set.delete minp f) $ c Map.! minp

main = do
  contents <- readFile "input.txt"
  let (p, _) = parsePath contents
      (c, _) = addPath (0, 0) p Map.empty
  print $ getOverThousandCount c (Map.singleton (0, 0) 0) (Set.singleton (0, 0))
