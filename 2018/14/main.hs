import Data.Char
import Data.Foldable
import qualified Data.Sequence as Seq

step :: (Seq.Seq Int, Int, Int) -> (Seq.Seq Int, Int, Int)
step (s, i, j) = (s', (i + 1 + ri) `mod` l, (j + 1 + rj) `mod` l)
  where ri = Seq.index s i
        rj = Seq.index s j
        r = ri + rj
        d0 = r `div` 10
        d1 = r `mod` 10
        s' = case d0 of 0 -> s Seq.|> d1; otherwise -> (s Seq.|> d0) Seq.|> d1
        l = Seq.length s'

stepUntilValue :: Seq.Seq Int -> (Seq.Seq Int, Int, Int) -> Int
stepUntilValue v (s, i, j)
  | Seq.drop l0 s' == v = l0
  | Seq.take lv (Seq.drop l1 s') == v = l1
  | otherwise = stepUntilValue v (s', i', j')
  where (s', i', j') = step (s, i, j)
        ls' = Seq.length s'
        lv = Seq.length v
        l0 = ls' - lv
        l1 = l0 - 1

main = do
  print $ stepUntilValue (fmap digitToInt $ Seq.fromList "704321") (Seq.fromList [3, 7], 0, 1)
