differByOne :: String -> String -> Maybe String
differByOne "" "" = Nothing
differByOne (h0:t0) (h1:t1)
  | h0 == h1 = case rest of Nothing -> Nothing; Just r -> Just (h0:r)
  | t0 == t1 = Just t0
  | otherwise = Nothing
  where rest = differByOne t0 t1

findDifferByOne :: String -> [String] -> Maybe String
findDifferByOne _ [] = Nothing
findDifferByOne s (h:t) = case differByOne s h of
  Nothing -> findDifferByOne s t
  match -> match

findDiffer :: [String] -> Maybe String
findDiffer [] = Nothing
findDiffer (h:t) = case findDifferByOne h t of
  Nothing -> findDiffer t
  match -> match

main = do
  contents <- readFile "input.txt"
  putStrLn $ show $ findDiffer $ lines contents
