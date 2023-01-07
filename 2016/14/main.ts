import md5 from 'md5'

function getTriplet (hash :string) {
  for (let ii = 0; ii < hash.length; ++ii) {
    const ch = hash[ii]
    if (hash[ii + 1] === ch && hash[ii + 2] === ch) return ch
  }
}

const input = 'ahsbgdzn'

const candidates :[number, string][] = []

let keyCount = 0

outer: for (let ii = 0;; ++ii) {
  while (candidates.length > 0 && ii - candidates[0][0] >= 1000) candidates.shift()
  let hash = input + ii
  for (let jj = 0; jj < 2017; ++jj) hash = md5(hash)
  for (let jj = 0; jj < candidates.length; ) {
    if (hash.indexOf(candidates[jj][1]) !== -1) {
      if (++keyCount == 64) {
        console.log(candidates[jj][0])
        break outer
      }
      candidates.splice(jj, 1)
    } else ++jj
  }
  const triplet = getTriplet(hash)
  if (triplet !== undefined) {
    candidates.push([ii, triplet.repeat(5)])
  }
}