import { readFileSync } from 'node:fs'
import { exit } from 'node:process'

let endpoints :[number, boolean][] = []

for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  if (line == '') continue
  const parts = line.split('-')
  endpoints.push([parseInt(parts[0]), true])
  endpoints.push([parseInt(parts[1]), false])
}

endpoints.sort((a, b) => {
  const diff = a[0] - b[0]
  return diff === 0 ? Number(a[1]) - Number(b[1]) : diff
})

let count = 0
let last = -1
let total = 0
for (let [value, start] of endpoints) {
  if (count === 0 && value > last + 1) {
    total += value - last - 1
  }
  if (start) count++
  else count--
  last = value
}
total += Math.pow(2, 32) - last - 1

console.log(total)

