import Data.Char

step :: String -> String
step [] = []
step (a:[]) = [a]
step (a:b:rest)
  | (toUpper a) == (toUpper b) && (isUpper a) /= (isUpper b) = step rest
  | otherwise = (a : step (b : rest))

stepUntilComplete :: String -> String
stepUntilComplete s =
  if s == s' then s else stepUntilComplete s'
  where s' = step s

reactWithout :: String -> Char -> Int
reactWithout s u = length $ stepUntilComplete $ filter (\c -> toUpper c /= u) s

main = do
  contents <- readFile "input.txt"
  print $ minimum $ map (reactWithout $ head $ lines contents) ['A' .. 'Z']
