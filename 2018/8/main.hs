data Node = Node [Node] [Int]

readNode :: [Int] -> (Node, [Int])
readNode (childCount:metadataCount:r) = (Node children metadata, r'')
  where (children, r') = readNodes r childCount
        (metadata, r'') = splitAt metadataCount r'

readNodes :: [Int] -> Int -> ([Node], [Int])
readNodes r 0 = ([], r)
readNodes r n = (head:tail, r'')
  where (head, r') = readNode r
        (tail, r'') = readNodes r' (n - 1)

metadataSum :: Node -> Int
metadataSum (Node children metadata) =
  (sum metadata) + (sum $ map metadataSum children)

nodeValue :: Node -> Int
nodeValue (Node [] metadata) = sum metadata
nodeValue (Node children metadata) =
  sum $ map (\m -> if m > 0 && m <= length children then nodeValue $ children !! (m - 1) else 0) metadata

main = do
  contents <- readFile "input.txt"
  let (root, _) = readNode $ map read $ words contents
  print $ nodeValue root
