import { readFileSync } from 'node:fs';

const digits = ['  1  ', ' 234 ', '56789', ' ABC ', '  D  ']
let pos = [2, 0]

let result = ''
for (let line of readFileSync('input.txt', 'utf8').split('\n')) {
  if (line == '') continue
  for (let ch of line) {
    let nextPos = pos.slice()
    switch (ch) {
      case 'U': nextPos[0]--; break
      case 'D': nextPos[0]++; break
      case 'L': nextPos[1]--; break
      case 'R': nextPos[1]++; break
    }
    if (nextPos[0] >= 0 && nextPos[0] <= 4 && nextPos[1] >= 0 && nextPos[1] <= 4 && digits[nextPos[0]][nextPos[1]] != ' ') {
      pos = nextPos
    }
  }
  result += digits[pos[0]][pos[1]]
}

console.log(result)