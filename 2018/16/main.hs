import Data.Bits
import Data.Foldable
import qualified Data.IntSet as IntSet
import qualified Data.Sequence as Seq

execOpcode :: [Int] -> Seq.Seq Int -> Seq.Seq Int
execOpcode [0, a, b, c] r = Seq.update c (Seq.index r a + Seq.index r b) r
execOpcode [1, a, b, c] r = Seq.update c (Seq.index r a + b) r
execOpcode [2, a, b, c] r = Seq.update c (Seq.index r a * Seq.index r b) r
execOpcode [3, a, b, c] r = Seq.update c (Seq.index r a * b) r
execOpcode [4, a, b, c] r = Seq.update c (Seq.index r a .&. Seq.index r b) r
execOpcode [5, a, b, c] r = Seq.update c (Seq.index r a .&. b) r
execOpcode [6, a, b, c] r = Seq.update c (Seq.index r a .|. Seq.index r b) r
execOpcode [7, a, b, c] r = Seq.update c (Seq.index r a .|. b) r
execOpcode [8, a, b, c] r = Seq.update c (Seq.index r a) r
execOpcode [9, a, b, c] r = Seq.update c a r
execOpcode [10, a, b, c] r = Seq.update c (if a > Seq.index r b then 1 else 0) r
execOpcode [11, a, b, c] r = Seq.update c (if Seq.index r a > b then 1 else 0) r
execOpcode [12, a, b, c] r = Seq.update c (if Seq.index r a > Seq.index r b then 1 else 0) r
execOpcode [13, a, b, c] r = Seq.update c (if a == Seq.index r b then 1 else 0) r
execOpcode [14, a, b, c] r = Seq.update c (if Seq.index r a == b then 1 else 0) r
execOpcode [15, a, b, c] r = Seq.update c (if Seq.index r a == Seq.index r b then 1 else 0) r

getOpcodes :: [Int] -> Seq.Seq Int -> Seq.Seq Int -> IntSet.IntSet
getOpcodes [a, b, c] before after =
  foldl (\s o -> if execOpcode [o, a, b, c] before == after then IntSet.insert o s else s) IntSet.empty [0..15]

readRegisters :: String -> Seq.Seq Int
readRegisters l = Seq.fromList [read a, read b, read c, read d]
  where l' = tail $ dropWhile (/= '[') l
        (a, l'') = span (/= ',') l'
        (b, l''') = span (/= ',') $ tail l''
        (c, l'''') = span (/= ',') $ tail l'''
        d = takeWhile (/= ']') $ tail l''''

getOptions :: Seq.Seq IntSet.IntSet -> [String] -> Seq.Seq IntSet.IntSet
getOptions o (b:c:a:_:rest)
  | length b == 0 = o
  | otherwise = getOptions (Seq.update opcode (IntSet.intersection (Seq.index o opcode) (getOpcodes args before after)) o) rest
  where before = readRegisters b
        command = map read $ words c
        opcode = head command
        args = tail command
        after = readRegisters a

narrowOptions :: Seq.Seq IntSet.IntSet -> Seq.Seq Int
narrowOptions o
  | IntSet.size ones == 16 = fmap (\s -> IntSet.findMin s) o
  | otherwise = narrowOptions $ fmap (\s -> if IntSet.size s > 1 then s IntSet.\\ ones else s) o
  where ones = foldl (\o s -> if IntSet.size s == 1 then IntSet.insert (IntSet.findMin s) o else o) IntSet.empty o

getCommands :: [String] -> [[Int]]
getCommands ("":"":"":rest) = map (\l -> map read $ words l) rest
getCommands (_:rest) = getCommands rest

main = do
  contents <- readFile "input.txt"
  let defs = narrowOptions $ getOptions (Seq.replicate 16 $ IntSet.fromList [0..15]) $ lines contents
      commands = getCommands $ lines contents
  print $ foldl (\r (o:args) -> execOpcode (Seq.index defs o : args) r) (Seq.replicate 4 0) commands
