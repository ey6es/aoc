import qualified Data.Set as Set

readNumber :: [Char] -> Int
readNumber s = read $ if head s == '+' then tail s else s

firstRepeated :: [Int] -> Set.Set Int -> Int
firstRepeated list seen
  | Set.member value seen = value
  | otherwise = firstRepeated (tail list) (Set.insert value seen)
  where value = head list

main = do
  contents <- readFile "input.txt"
  putStrLn $ show $ firstRepeated (scanl1 (+) $ cycle $ map readNumber $ lines contents) Set.empty
