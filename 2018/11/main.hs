import qualified Data.Map as Map

getPowerLevel :: Int -> (Int, Int) -> Int
getPowerLevel serialNumber (x, y) = p''' - 5
  where rackId = x + 10
        p = rackId * y
        p' = p + serialNumber
        p'' = p' * rackId
        p''' = (p'' `div` 100) `mod` 10

addLists :: [Int] -> [Int] -> [Int]
addLists [] [] = []
addLists (ha:ta) (hb:tb) = (ha + hb : addLists ta tb)

getPowerSum :: Int -> Int -> Int -> Map.Map (Int, Int) Int -> Int
getPowerSum x y s m =
  Map.findWithDefault 0 (x + s - 1, y + s - 1) m -
  Map.findWithDefault 0 (x + s - 1, y - 1) m -
  Map.findWithDefault 0 (x - 1, y + s - 1) m +
  Map.findWithDefault 0 (x - 1, y - 1) m

foldPowerSum :: Map.Map (Int, Int) Int -> ((Int, Int, Int), Int) -> (Int, Int, Int) -> ((Int, Int, Int), Int)
foldPowerSum m (mp, mt) (x, y, s)
  | t > mt = ((x, y, s), t)
  | otherwise = (mp, mt)
  where t = getPowerSum x y s m

main = do
  contents <- readFile "input.txt"
  let serialNumber = read contents :: Int
      sums = scanl1 (addLists) $ map (\y -> scanl1 (+) $ map (\x -> getPowerLevel serialNumber (x, y)) [1..300]) [1..300]
      m = foldl (\m (y, r) -> foldl (\m (x, s) -> Map.insert (x, y) s m) m (zip [1..300] r)) Map.empty (zip [1..300] sums)
      (p, _) = foldl (foldPowerSum m) ((0, 0, 0), 0) [(x, y, s) | s <- [3..300], x <- [1..300 - s + 1], y <- [1..300 - s + 1]]
  print p
