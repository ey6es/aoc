import { readFileSync } from 'node:fs';

let entries: number[][] = []
let regex = /^\s+(\d+)\s+(\d+)\s+(\d+)$/
for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  let sides = regex.exec(line)?.slice(1).map(p => parseInt(p))
  if (sides) entries.push(sides)
}

let total = 0
for (let ii = 0; ii < entries.length; ii += 3) {
  for (let jj = 0; jj < 3; ++jj) {
    let [a, b, c] = [entries[ii][jj], entries[ii + 1][jj], entries[ii + 2][jj]]
    if (a + b > c && a + c > b && b + c > a) total++
  }
}

console.log(total)