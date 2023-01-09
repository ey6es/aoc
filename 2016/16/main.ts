const input = '10010000000110000'
const size = 35651584

const bits = [0]
for (let ii = 0; ii < input.length; ++ii) {
  if (input[ii] === '1') bits[0] |= (1 << ii)
}

let currentLength = input.length
while (currentLength < size) {
  const nextLength = currentLength * 2 + 1
  for (let ii = 0; ii < currentLength; ++ii) {
    const src = currentLength - 1 - ii
    if ((bits[src >> 5] & 1 << (src & 31)) === 0) {
      const dest = currentLength + 1 + ii
      const destIndex = dest >> 5
      while (bits.length <= destIndex) bits.push(0)
      bits[destIndex] |= 1 << (dest & 31)
    }
  }
  currentLength = nextLength
}

let targetSize = size
while (targetSize % 2 == 0) targetSize /= 2

let result = ''
const bitsPerElement = size / targetSize
for (let ii = 0; ii < size; ) {
  let total = 0
  for (let nn = ii + bitsPerElement; ii < nn; ++ii) {
    if ((bits[ii >> 5] & 1 << (ii & 31)) !== 0) total++
  }
  result += (total & 1) == 0 ? '1' : '0'
}

console.log(result)