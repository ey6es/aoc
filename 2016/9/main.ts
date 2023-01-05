import { readFileSync } from 'node:fs'

const input = readFileSync('input.txt', 'utf8').trim()

function getLength(start :number, end :number) :number {
  let total = 0
  for (let ii = start; ii < end; ++ii) {
    if (input[ii] != '(') {
      total++
      continue
    }
    const jj = input.indexOf(')', ii + 1)
    const parts = input.substring(ii + 1, jj).split('x').map(p => parseInt(p))
    total += getLength(jj + 1, jj + 1 + parts[0]) * parts[1]
    ii = jj + parts[0]
  }
  return total
}

console.log(getLength(0, input.length))

