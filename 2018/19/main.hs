import Data.Bits
import qualified Data.Sequence as Seq

type Instruction = (String, Int, Int, Int)

execOpcode :: Instruction -> Seq.Seq Int -> Seq.Seq Int
execOpcode ("addr", a, b, c) r = Seq.update c (Seq.index r a + Seq.index r b) r
execOpcode ("addi", a, b, c) r = Seq.update c (Seq.index r a + b) r
execOpcode ("mulr", a, b, c) r = Seq.update c (Seq.index r a * Seq.index r b) r
execOpcode ("muli", a, b, c) r = Seq.update c (Seq.index r a * b) r
execOpcode ("banr", a, b, c) r = Seq.update c (Seq.index r a .&. Seq.index r b) r
execOpcode ("bani", a, b, c) r = Seq.update c (Seq.index r a .&. b) r
execOpcode ("borr", a, b, c) r = Seq.update c (Seq.index r a .|. Seq.index r b) r
execOpcode ("bori", a, b, c) r = Seq.update c (Seq.index r a .|. b) r
execOpcode ("setr", a, b, c) r = Seq.update c (Seq.index r a) r
execOpcode ("seti", a, b, c) r = Seq.update c a r
execOpcode ("gtir", a, b, c) r = Seq.update c (if a > Seq.index r b then 1 else 0) r
execOpcode ("gtri", a, b, c) r = Seq.update c (if Seq.index r a > b then 1 else 0) r
execOpcode ("gtrr", a, b, c) r = Seq.update c (if Seq.index r a > Seq.index r b then 1 else 0) r
execOpcode ("eqir", a, b, c) r = Seq.update c (if a == Seq.index r b then 1 else 0) r
execOpcode ("eqri", a, b, c) r = Seq.update c (if Seq.index r a == b then 1 else 0) r
execOpcode ("eqrr", a, b, c) r = Seq.update c (if Seq.index r a == Seq.index r b then 1 else 0) r

foldLine :: (Int, Seq.Seq Instruction) -> String -> (Int, Seq.Seq Instruction)
foldLine (ip, is) l
  | head l == '#' = (read $ head $ tail w, is)
  | otherwise = (ip, is Seq.|> (head w, read $ w !! 1, read $ w !! 2, read $ w !! 3))
  where w = words l

execUntilBreak :: Int -> Seq.Seq Instruction -> Seq.Seq Int -> Int
execUntilBreak ip is r
  | i < 0 || i >= Seq.length is = Seq.index r 0
  | otherwise = execUntilBreak ip is r''
  where i = Seq.index r ip
        r' = execOpcode (Seq.index is i) r
        i' = Seq.index r' ip
        r'' = Seq.update ip (i' + 1) r'

main = do
  contents <- readFile "input.txt"
  let (ip, is) = foldl foldLine (0, Seq.empty) $ lines contents
  print $ execUntilBreak ip is $ Seq.fromList [0, 0, 0, 0, 0, 0]
