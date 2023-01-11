import { readFileSync } from 'node:fs'

const data = readFileSync('input.txt', 'utf8').split('\n')

const width = data[0].length
const height = data.length

const locations :[number, number][] = []

function getLocationIndex (pos :[number, number]) {
  const index = data[pos[0]][pos[1]].charCodeAt(0) - '0'.charCodeAt(0)
  return index >= 0 && index <= 9 ? index : undefined
}

for (let row = 0; row < height; ++row) {
  if (data[row] == '') continue
  for (let col = 0; col < width; ++col) {
    const index = getLocationIndex([row, col])
    if (index !== undefined) locations[index] = [row, col]
  }
}

type FringeElement = [number, [number, number]]

const distances :number[][] = []

const offsets = [[0, -1], [0, 1], [-1, 0], [1, 0]]

for (let ii = 0; ii < locations.length; ++ii) {
  let fringe :[number, number][] = [locations[ii]]

  const map :boolean[][] = []
  for (let row = 0; row < height; ++row) {
    map.push([])
    for (let col = 0; col < width; ++col) {
      map[row][col] = data[row][col] !== '#'
    }
  }

  distances.push([])
  let remaining = locations.length

  outer: for (let dist = 0;; ++dist) {
    const nextFringe :[number, number][] = []
    for (const pos of fringe) {
      const index = getLocationIndex(pos)
      if (index !== undefined && distances[ii][index] === undefined) {
        distances[ii][index] = dist
        if (--remaining === 0) break outer
      }
    }
    for (const pos of fringe) {
      for (const offset of offsets) {
        const nextPos :[number, number] = [pos[0] + offset[0], pos[1] + offset[1]]
        if (map[nextPos[0]][nextPos[1]]) {
          map[nextPos[0]][nextPos[1]] = false
          nextFringe.push(nextPos)
        }
      }
    }
    fringe = nextFringe
  }
}

function getMinimumTotal (start :number, remaining :number) {
  let minimum = Number.MAX_VALUE
  for (let ii = 0; ii < locations.length; ++ii) {
    const flag = 1 << ii
    if ((remaining & flag) !== 0) {
      const nextRemaining = remaining ^ flag
      minimum = Math.min(minimum, distances[start][ii] +
        (nextRemaining === 0 ? distances[ii][0] : getMinimumTotal(ii, nextRemaining)))
    }
  }
  return minimum
}

console.log(getMinimumTotal(0, (1 << locations.length) - 2))
