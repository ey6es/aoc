import { readFileSync } from 'node:fs'

let total = 0
for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  const outside = new Set()
  const inside = new Set()
  let inBrackets = false
  for (let ii = 0; ii < line.length; ++ii) {
    if (line[ii] == '[') inBrackets = true
    else if (line[ii] == ']') inBrackets = false
    else if (line[ii + 1] != line[ii] && line[ii + 2] == line[ii]) {
      if (inBrackets) inside.add(line[ii + 1] + line[ii])
      else outside.add(line[ii] + line[ii + 1])
    }
  }
  for (let pattern of outside) {
    if (inside.has(pattern)) {
      total++
      break
    }
  }
}

console.log(total)