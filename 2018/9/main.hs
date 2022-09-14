import qualified Data.IntMap as IntMap
import qualified Data.Sequence as Seq

updateState :: Int -> (Seq.Seq Int, Int, IntMap.IntMap Int) -> Int -> (Seq.Seq Int, Int, IntMap.IntMap Int)
updateState numPlayers (marbles, currentMarble, scores) marbleValue
  | marbleValue `mod` 23 == 0 = let currentPlayer = (marbleValue - 1) `mod` numPlayers
                                    s' = IntMap.insertWith (+) currentPlayer marbleValue scores
                                    newCurrentMarble = (currentMarble + Seq.length marbles - 7) `mod` (Seq.length marbles)
                                    s'' = IntMap.insertWith (+) currentPlayer (marbles `Seq.index` newCurrentMarble) s'
                                    (before, after) = Seq.splitAt newCurrentMarble marbles
                                in (before Seq.>< (Seq.drop 1 after), newCurrentMarble, s'')
  | otherwise = let newCurrentMarble = 1 + succ currentMarble `mod` Seq.length marbles
                    (before, after) = Seq.splitAt newCurrentMarble marbles
                in (before Seq.>< (marbleValue Seq.<| after), newCurrentMarble, scores)

main = do
  contents <- readFile "input.txt"
  let w = words contents
      numPlayers = read $ head w :: Int
      lastMarble = read $ w !! 6 :: Int
      (_, _, scores) = foldl (updateState numPlayers) (Seq.singleton 0, 0, IntMap.empty) [1..lastMarble]
  print $ maximum $ IntMap.elems scores
