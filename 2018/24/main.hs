import Data.Bits
import Data.Char
import qualified Data.Foldable as Foldable
import qualified Data.Sequence as Seq
import Debug.Trace

data Unit = Unit { team :: Int,
                   count :: Int,
                   hp :: Int,
                   weaknesses :: Int,
                   immunities :: Int,
                   damage :: Int,
                   damageType :: Int,
                   initiative :: Int } deriving (Eq, Show)

readDamageType :: String -> Int
readDamageType "radiation" = 0
readDamageType "fire" = 1
readDamageType "bludgeoning" = 2
readDamageType "slashing" = 3
readDamageType "cold" = 4

readModList :: [String] -> Int
readModList (w:r)
  | head c == ',' = bits .|. (readModList r)
  | otherwise = bits
  where (dt, c) = span isAlpha w
        bits = shift 1 $ readDamageType dt

combineMods :: (Int, Int) -> (Int, Int) -> (Int, Int)
combineMods (wk0, im0) (wk1, im1) = (wk0 .|. wk1, im0 .|. im1)

readMods :: String -> (Int, Int)
readMods "" = (0, 0)
readMods s = combineMods (wk, im) $ readMods n
  where s' = tail s
        w = words s'
        n = dropWhile (/=';') s'
        ml = readModList $ drop 2 w
        (wk, im) = if head w == "weak" then (ml, 0) else (0, ml)

readUnit :: Int -> String -> Unit
readUnit t s = Unit {team=t, count=c, hp=h, weaknesses=wk, immunities=im, damage=d, damageType=dt, initiative=i}
  where w = words s
        c = read $ head w
        h = read (w !! 4)
        (wk, im) = readMods $ dropWhile (/='(') s
        r = reverse w
        d = read (r !! 5)
        dt = readDamageType (r !! 4)
        i = read $ head r

effectivePower :: Unit -> Int
effectivePower u = count u * damage u

damageTotal :: Unit -> Unit -> Int
damageTotal u tu
  | immunities tu .&. damageBit /= 0 = 0
  | weaknesses tu .&. damageBit /= 0 = 2 * ep
  | otherwise = ep
  where damageBit = shift 1 $ damageType u
        ep = effectivePower u

foldTarget :: Unit -> Seq.Seq Int -> (Int, (Int, Int, Int)) -> Int -> Unit -> (Int, (Int, Int, Int))
foldTarget u ts (maxid, maxval) tid tu
  | count u > 0 && team u /= team tu && count tu > 0 && val > maxval && Foldable.notElem tid ts = (tid, val)
  | otherwise = (maxid, maxval)
  where val = (damageTotal u tu, effectivePower tu, initiative tu)

chooseTarget :: Seq.Seq Unit -> Seq.Seq Int -> Int -> Seq.Seq Int
chooseTarget us ts i = Seq.update i t ts
  where u = Seq.index us i
        (t, _) = Seq.foldlWithIndex (foldTarget u ts) (-1, (0, maxBound, maxBound)) us

targetSelectionCompare :: Seq.Seq Unit -> Int -> Int -> Ordering
targetSelectionCompare us a b = compare (effectivePower bu, initiative bu) (effectivePower au, initiative au)
  where (au, bu) = (Seq.index us a, Seq.index us b)

initiativeCompare :: Seq.Seq Unit -> Int -> Int -> Ordering
initiativeCompare us a b = compare (initiative bu) (initiative au)
  where (au, bu) = (Seq.index us a, Seq.index us b)

applyAttack :: Seq.Seq Int -> Seq.Seq Unit -> Int -> Seq.Seq Unit
applyAttack ts us i
  | count u == 0 || t == -1 || dt == 0 = us
  | otherwise = Seq.update t (tu {count=nc}) us
  where u = Seq.index us i
        t = Seq.index ts i
        tu = Seq.index us t
        dt = damageTotal u tu
        nc = max 0 $ count tu - dt `div` hp tu

fight :: Seq.Seq Unit -> Seq.Seq Unit
fight us = us'
  where tis = Seq.sortBy (targetSelectionCompare us) $ Seq.fromList [0..Seq.length us - 1]
        ts = Foldable.foldl (chooseTarget us) (Seq.replicate (Seq.length us) (-1)) tis
        iis = Seq.sortBy (initiativeCompare us) $ Seq.fromList [0..Seq.length us - 1]
        us' = Foldable.foldl (applyAttack ts) us iis

fightUntilComplete :: Seq.Seq Unit -> Int
fightUntilComplete us
  | c0 == 0 = 0
  | c1 == 0 = c0
  | us' == us = 0
  | otherwise = fightUntilComplete us'
  where (c0, c1) = Foldable.foldl (\(c0, c1) u -> if team u == 0 then (c0 + count u, c1) else (c0, c1 + count u)) (0, 0) us
        us' = fight us

boostUntilImmunized :: Seq.Seq Unit -> Int -> Int
boostUntilImmunized us boost
  | c > 0 = c
  | otherwise = boostUntilImmunized us (boost + 1)
  where c = fightUntilComplete $ fmap (\u -> if team u == 0 then u {damage=damage u + boost} else u) us

main = do
  contents <- readFile "input.txt"
  let (p0, p1) = span (/="") $ lines contents
      us = Seq.fromList $ (map (readUnit 0) $ tail p0) ++ (map (readUnit 1) $ tail $ tail p1)
  print $ boostUntilImmunized us 0
