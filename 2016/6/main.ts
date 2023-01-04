import { readFileSync } from 'node:fs'

const input = readFileSync('input.txt', 'utf8').split('\n')
let output = ''
for (let ii = 0, nn = input[0].length; ii < nn; ++ii) {
  const counts = new Map()
  for (let line of input) {
    if (line != '') counts.set(line[ii], (counts.get(line[ii]) ?? 0) + 1)
  }
  let minCount = Number.MAX_VALUE
  let minChar = ''
  for (let [char, count] of counts) {
    if (count < minCount) {
      minCount = count
      minChar = char
    }
  }
  output += minChar
}

console.log(output)