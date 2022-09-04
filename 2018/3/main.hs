import Data.List
import qualified Data.Map as Map

type Area = (Int, (Int, Int), (Int, Int))

readArea :: String -> Area
readArea s =
  (id, (x, y), (w, h))
  where
    ws = words s
    id = read $ tail $ head ws :: Int
    elements = drop 2 $ ws
    [x, y] = map read $ words $ map (\c -> if c == ',' then ' ' else c) $ init $ head elements :: [Int]
    [w, h] = map read $ words $ map (\c -> if c == 'x' then ' ' else c) $ last elements :: [Int]

type AreaMap = Map.Map (Int, Int) Int

areaList :: Area -> [(Int, Int)]
areaList (_, (x, y), (w, h)) = [(x', y') | x' <- [x .. (x + w - 1)], y' <- [y .. (y + h - 1)]]

insertArea :: AreaMap -> Area -> AreaMap
insertArea m area = foldl (\m coord -> Map.insertWith (+) coord 1 m) m $ areaList area

areaClear :: AreaMap -> Area -> Bool
areaClear m area = foldl (\b c -> b && m Map.! c == 1) True $ areaList area

main = do
  contents <- readFile "input.txt"
  let areas = map readArea $ lines contents
      m = foldl insertArea Map.empty areas
  print $ find (\a -> areaClear m a) areas
