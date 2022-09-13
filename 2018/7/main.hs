import Data.Char
import Data.List
import qualified Data.Map as Map

readPair :: String -> (Char, Char)
readPair s =
  (head $ head $ tail w, head $ head $ drop 7 w)
  where w = words s

haveDeps :: Char -> Map.Map Char String -> String -> Bool
haveDeps c deps finished =
  case Map.lookup c deps of Just d -> d \\ finished == ""; otherwise -> True

updateState :: Map.Map Char String -> String -> (Char, Int) -> (String, [(Char, Int)]) -> (String, [(Char, Int)])
updateState deps finished (c, r) (remaining, states)
  | r == 0 = case find (\c -> haveDeps c deps finished) remaining of
                  Just c -> (delete c remaining, (c, 60 + (ord c) - (ord 'A')):states)
                  Nothing -> (remaining, ('_', 0):states)
  | otherwise = (remaining, (c, r - 1):states)

countSteps :: Map.Map Char String -> String -> String -> [(Char, Int)] -> Int
countSteps deps remaining finished states
  | length finished == 26 = 0
  | otherwise = 1 + countSteps deps nextRemaining nextFinished nextStates
  where nextFinished = foldl (\f (c, r) -> if r == 0 && c /= '_' then (c:f) else f) finished states
        (nextRemaining, nextStates) = foldr (updateState deps nextFinished) (remaining, []) states

main = do
  contents <- readFile "input.txt"
  let pairs = map readPair $ lines contents
      deps = foldl (\m (p, c) -> Map.insertWith (++) c (p:"") m) Map.empty pairs
  print $ countSteps deps ['A'..'Z'] "" [('_', 0), ('_', 0), ('_', 0), ('_', 0), ('_', 0)] - 1
