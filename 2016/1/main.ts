import { readFileSync } from 'node:fs';

let dir = 0
let pos = [0, 0]

const offsets = [[0, -1], [1, 0], [0, 1], [-1, 0]]
let visited = new Set()

outer: for (let element of readFileSync('input.txt', 'utf8').split(', ')) {
  if (element[0] == 'R') dir = (dir + 1) % 4
  else dir = (dir + 3) % 4

  let length = parseInt(element.substring(1))
  for (let ii = 0; ii < length; ++ii) {
    pos[0] += offsets[dir][0]
    pos[1] += offsets[dir][1]
    let string = pos.toString()
    if (visited.has(string)) {
      console.log(Math.abs(pos[0]) + Math.abs(pos[1]))
      break outer
    }
    visited.add(string)
  }
}
