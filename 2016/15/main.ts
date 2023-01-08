import { readFileSync } from 'node:fs'

function positiveModulo (a :number, b : number) {
  const result = a % b
  return result < 0 ? (result + b) : result
}

// https://www.geeksforgeeks.org/modular-division/
function gcdExtended (a :number, b :number) :[number, number, number] {
  if (a === 0) return [0, 1, b]
  const [x, y, gcd] = gcdExtended(b % a, a)
  return [y - Math.floor(b/a) * x, x, gcd]
}

const discs :[number, number][] = []

let index = 1
let combinedPeriod = 0
let combinedOffset = 0
for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  if (line == '') continue
  const parts = line.split(' ')
  const period = parseInt(parts[3])
  const start = parseInt(parts[11].substring(0, parts[11].length - 1))
  const offset = (period - (start + index++) % period) % period
  if (combinedPeriod === 0) {
    combinedPeriod = period
    combinedOffset = offset
    continue
  }
  const [maxOffset, maxPeriod, minOffset, minPeriod] = combinedOffset > offset
    ? [combinedOffset, combinedPeriod, offset, period]
    : [offset, period, combinedOffset, combinedPeriod]
  const delta = maxOffset - minOffset
  const multiple = positiveModulo(-delta * gcdExtended(maxPeriod, minPeriod)[0], minPeriod)
  combinedOffset = maxOffset + multiple * maxPeriod
  combinedPeriod = combinedPeriod * period
}

console.log(combinedOffset)

