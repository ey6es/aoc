type State = ((Int, Int), (Int, Int))
type Extents = ((Int, Int), (Int, Int))

readState :: String -> State
readState s = ((px, py), (vx, vy))
  where s' = dropWhile (/='<') s
        px = read $ head $ words $ takeWhile (/=',') $ tail s'
        s'' = dropWhile (/=',') s'
        py = read $ head $ words $ takeWhile (/='>') $ tail s''
        s''' = dropWhile (/='<') s''
        vx = read $ head $ words $ takeWhile (/=',') $ tail s'''
        s'''' = dropWhile (/=',') s'''
        vy = read $ head $ words $ takeWhile (/='>') $ tail s''''

updateStates :: [State] -> [State]
updateStates states = map (\((px, py), (vx, vy)) -> ((px + vx, py + vy), (vx, vy))) states

foldExtent :: Extents -> State -> Extents
foldExtent ((minx, miny), (maxx, maxy)) ((px, py), _) = ((min minx px, min miny py), (max maxx px, max maxy py))

getExtents :: [State] -> Extents
getExtents states = foldl1 foldExtent states

getArea :: [State] -> Int
getArea states = (maxx - minx + 1) * (maxy - miny + 1)
                 where ((minx, miny), (maxx, maxy)) = getExtents states

updateUntilGrowth :: [State] -> ([State], Int)
updateUntilGrowth states
  | getArea nextStates > getArea states = (states, 0)
  | otherwise = let (finalStates, count) = updateUntilGrowth nextStates in (finalStates, count + 1)
  where nextStates = updateStates states

toChar :: [State] -> Int -> (Int, Int) -> Char
toChar states maxx (x, y)
  | x > maxx = '\n'
  | any (\((px, py), _) -> px == x && py == y) states = 'X'
  | otherwise = ' '

main = do
  contents <- readFile "input.txt"
  let (states, count) = updateUntilGrowth $ map readState $ lines contents
      ((minx, miny), (maxx, maxy)) = getExtents states
      image = map (toChar states maxx) [(x, y) | y <- [miny .. maxy], x <- [minx .. maxx + 1]]
  putStr image
  print count
