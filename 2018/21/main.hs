import Data.Bits
import qualified Data.IntSet as IntSet

mul24 :: Int -> Int -> Int
mul24 a b = (((a + b) .&. 16777215) * 65899) .&. 16777215

compute :: Int -> Int
compute v = p''
            where v' = v .|. 65536
                  p = mul24 16123384 (v' .&. 255)
                  p' = mul24 p ((shift v' (-8)) .&. 255)
                  p'' = mul24 p' ((shift v' (-16)) .&. 255)

computeUntilRepeat :: Int -> IntSet.IntSet -> Int
computeUntilRepeat v s
  | IntSet.member v' s = v
  | otherwise = computeUntilRepeat v' $ IntSet.insert v s
  where v' = compute v

main = do
  print $ computeUntilRepeat 0 IntSet.empty
