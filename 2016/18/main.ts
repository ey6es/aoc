import { readFileSync } from 'node:fs'

const input = readFileSync('input.txt', 'utf8').trim()

let line = 0n
for (let ii = 0, flag = 1n; ii < input.length; ++ii, flag <<= 1n) {
  if (input[ii] == '^') line |= flag
}

let total = 0
const mask = (1n << BigInt(input.length)) - 1n
for (let ii = 0; ii < 400000; ++ii) {
  let str = ''
  for (let jj = 0, flag = 1n; jj < input.length; ++jj, flag <<= 1n) {
    if ((line & flag) === 0n) {
      total++
      str += '.'
    } else {
      str += '^'
    }
  }
  line = ((line >> 1n) ^ (line << 1n)) & mask
}

console.log(total)