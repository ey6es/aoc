import Data.List
import qualified Data.Map as Map

type Tracks = Map.Map (Int, Int) Char
type Carts = Map.Map (Int, Int) (Int, Int)
type State = (Tracks, Carts)

foldChar :: Int -> State -> (Int, Char) -> State
foldChar y (t, c) (x, v)
  | v == 'v' = (Map.insert (y, x) '|' t, Map.insert (y, x) (2, 0) c)
  | v == '^' = (Map.insert (y, x) '|' t, Map.insert (y, x) (0, 0) c)
  | v == '<' = (Map.insert (y, x) '-' t, Map.insert (y, x) (3, 0) c)
  | v == '>' = (Map.insert (y, x) '-' t, Map.insert (y, x) (1, 0) c)
  | otherwise = (Map.insert (y, x) v t, c)

getDirectionState :: Int -> Int -> Char -> (Int, Int)
getDirectionState d s '+' = ((d + (s - 1) + 4) `mod` 4, (s + 1) `mod` 3)
getDirectionState d s '/' = ((5 - d) `mod` 4, s)
getDirectionState d s '\\' = (3 - d, s)
getDirectionState d s _ = (d, s)

data Result = Multiple Carts | Single (Int, Int)

foldCart :: Tracks -> Carts -> (Int, Int) -> (Int, Int) -> Carts
foldCart t c (y, x) (d, s)
  | Map.notMember (y, x) c = c
  | Map.member (y', x') c' = Map.delete (y', x') c'
  | otherwise = Map.insert (y', x') (d', s') c'
  where y' = case d of 0 -> y - 1; 2 -> y + 1; otherwise -> y
        x' = case d of 3 -> x - 1; 1 -> x + 1; otherwise -> x
        c' = Map.delete (y, x) c
        (d', s') = getDirectionState d s (t Map.! (y', x'))

updateCarts :: Tracks -> Carts -> Result
updateCarts t c
  | Map.size c' == 1 = Single (head $ Map.keys c')
  | otherwise = Multiple c'
  where c' = Map.foldlWithKey (foldCart t) c c

updateUntilSingle :: Tracks -> Carts -> (Int, Int)
updateUntilSingle t c = case updateCarts t c of Multiple c' -> updateUntilSingle t c'; Single (y, x) -> (x, y)

main = do
  contents <- readFile "input.txt"
  let (t, c) = foldl (\s (y, l) -> foldl (foldChar y) s $ zip [0..] $ l) (Map.empty, Map.empty) $ zip [0..] $ lines contents
  print $ updateUntilSingle t c
